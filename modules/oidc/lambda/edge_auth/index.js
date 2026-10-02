'use strict';

const crypto = require('crypto');
const querystring = require('querystring');

// Load config as list and convert to map by application_name. Lambda@Edge uses the
// generated config.json; tests can inject OIDC_CONFIG_JSON because Lambda@Edge does not
// support environment variables in production.
const configList = process.env.OIDC_CONFIG_JSON ? JSON.parse(process.env.OIDC_CONFIG_JSON) : require('./config.json');
const config = Object.fromEntries(configList.map(cfg => [cfg.application_name, cfg]));

function cookieValue(entry) {
  const index = entry.indexOf('=');
  return index === -1 ? '' : entry.slice(index + 1);
}

function base64UrlEncode(value) {
  return Buffer.from(value, 'utf8').toString('base64url');
}

exports.handler = (event, context, callback) => {
  try {
    console.log('Edge Lambda - Received event:', JSON.stringify(event, null, 2));

    // Verify event format
    if (!event.Records || !event.Records[0] || !event.Records[0].cf || !event.Records[0].cf.request) {
      console.error('Edge Lambda - Invalid event format:', JSON.stringify(event, null, 2));
      return callback(null, {
        status: '400',
        statusDescription: 'Bad Request',
        body: 'Invalid event format',
      });
    }

    const request = event.Records[0].cf.request;
    const headers = request.headers || {};
    const query = request.querystring || '';
    const params = querystring.parse(query);
    const authParam = params.auth; // just for logging/debug

    let providerKey = null;
    console.log('Edge Lambda - Query params:', { authParam });

    // Extract session cookie & providerKey from cookies
    let session = null;
    if (headers.cookie && Array.isArray(headers.cookie)) {
      for (const cookie of headers.cookie) {
        const cookieHeader = cookie.value || '';
        const cookieEntries = cookieHeader.split('; ').map(entry => entry.trim());
        for (const entry of cookieEntries) {
          if (entry.startsWith('session=')) {
            session = cookieValue(entry);
          } else if (entry.startsWith('auth_provider=')) {
            providerKey = cookieValue(entry);
          }
        }
        if (session && providerKey) break;
      }
    } else {
      console.log('Edge Lambda - No cookie header present or not an array');
    }

    // Determine provider for this request. Stale cookies should not lock a viewer out;
    // fall back to a valid query param or the default configured provider.
    let selectedProviderKey = null;
    if (!providerKey || !config[providerKey]) {
      selectedProviderKey = params.auth && config[params.auth] ? params.auth : Object.keys(config)[0];
      providerKey = selectedProviderKey;
      console.log('Edge Lambda - Using query param or default provider:', providerKey);
    } else {
      selectedProviderKey = providerKey;
      console.log('Edge Lambda - Using provider from cookie:', providerKey);
    }

    // Validate session cookie if present
    if (session) {
      if (!providerKey || !config[providerKey]) {
        console.log('Edge Lambda - Invalid or missing providerKey in config:', providerKey);
      } else {
        const provider = config[providerKey];

        // JWT-like format: value.signature
        if (session.includes('.')) {
          const [value, signature] = session.split('.');
          const expectedSignature = crypto
            .createHmac('sha256', provider.session_secret || '')
            .update(value)
            .digest('hex');
          console.log('Edge Lambda - Validating session for provider:', providerKey);
          if (signature === expectedSignature) {
            try {
              const sessionJson = Buffer.from(value, 'base64').toString('utf-8');
              const sessionPayload = JSON.parse(sessionJson);
              const now = Date.now();
              if (!sessionPayload.exp || now < sessionPayload.exp) {
                console.log('Edge Lambda - Session validated successfully for provider:', providerKey);
                return callback(null, request);
              } else {
                console.log('Edge Lambda - Session expired');
              }
            } catch (err) {
              console.log('Edge Lambda - Failed to parse session payload:', err.message);
              console.log('Edge Lambda - Accepting valid signature as opaque token');
              return callback(null, request);
            }
          } else {
            console.log('Edge Lambda - Session validation failed for provider:', providerKey);
          }
        } else {
          // Opaque token: base64-encoded JSON
          try {
            const sessionJson = Buffer.from(session, 'base64').toString('utf-8');
            const sessionPayload = JSON.parse(sessionJson);
            const now = Date.now();
            if (!sessionPayload.exp || now < sessionPayload.exp) {
              console.log('Edge Lambda - Opaque session validated successfully for provider:', providerKey);
              return callback(null, request);
            } else {
              console.log('Edge Lambda - Opaque session expired');
            }
          } catch (err) {
            console.log('Edge Lambda - Failed to parse opaque session payload:', err.message);
          }
        }
      }
    } else {
      console.log('Edge Lambda - No session cookie found');
    }

    // Redirect to OIDC if session is invalid or not present
    if (!providerKey || !config[providerKey]) {
      console.log('Edge Lambda - No matching provider for:', providerKey);
      return callback(null, {
        status: '403',
        statusDescription: 'Forbidden',
        body: 'No matching OIDC provider.',
      });
    }

    const provider = config[providerKey];
    const state = `${crypto.randomBytes(16).toString('hex')}.${base64UrlEncode(providerKey)}`;
    const loginUrl = `${provider.auth_url}?` +
      `client_id=${encodeURIComponent(provider.client_id)}` +
      `&redirect_uri=${encodeURIComponent(provider.redirect_uri)}` +
      `&response_type=code&scope=openid&state=${state}`;

    console.log('Edge Lambda - Redirecting to OIDC provider:', loginUrl);
    console.log('Edge Lambda - Setting state cookie:', state);

    // Prepare set-cookie headers
    const setCookieHeaders = [{
      key: 'Set-Cookie',
      value: `state=${state}; Path=/; HttpOnly; Secure; SameSite=None; Max-Age=300`,
    }];

    setCookieHeaders.push({
      key: 'Set-Cookie',
      value: `auth_provider=${selectedProviderKey}; Path=/; HttpOnly; Secure; SameSite=None; Max-Age=900`,
    });

    return callback(null, {
      status: '302',
      statusDescription: 'Found',
      headers: {
        location: [{
          key: 'Location',
          value: loginUrl,
        }],
        'set-cookie': setCookieHeaders,
      },
    });
  } catch (error) {
    console.error('Edge Lambda - Error:', error.message, error.stack);
    return callback(null, {
      status: '500',
      statusDescription: 'Internal Server Error',
      body: 'Edge Lambda failed to process the request',
    });
  }
};