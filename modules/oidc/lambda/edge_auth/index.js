'use strict';

const crypto = require('crypto');
const querystring = require('querystring');

const config = require('./config.json');

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
    const providerKey = params.auth;

    console.log('Edge Lambda - Query params:', { providerKey });

    // Extract session cookie
    let session = null;
    if (headers.cookie && Array.isArray(headers.cookie)) {
      //console.log('Edge Lambda - Cookies:', headers.cookie);
      for (const cookie of headers.cookie) {
        const cookieValue = cookie.value || '';
        //console.log('Edge Lambda - Processing cookie string:', cookieValue);
        // Split cookies delimited by semicolon or space
        const cookieEntries = cookieValue.split('; ').map(entry => entry.trim());
        for (const entry of cookieEntries) {
          if (entry.startsWith('session=')) {
            session = entry.split('=')[1];
            //console.log('Edge Lambda - Extracted session cookie:', session);
            break;
          }
        }
        if (session) break;
      }
    } else {
      console.log('Edge Lambda - No cookie header present or not an array');
    }

    // Validate session cookie if present
    if (session) {
      //console.log('Edge Lambda - Found session cookie:', session);
      // Check session cookie format (value.signature)
      if (!session.includes('.')) {
        console.log('Edge Lambda - Invalid session cookie format:', session);
      } else {
        const [value, signature] = session.split('.');
        //console.log('Edge Lambda - Session cookie parts - Value:', value, 'Signature:', signature);

        // Validate for selected provider if providerKey is present
        if (providerKey && config[providerKey]) {
          const provider = config[providerKey];
          //console.log('Edge Lambda - Provider config:', JSON.stringify(provider, null, 2));
          const expectedSignature = crypto
            .createHmac('sha256', provider.session_secret || '')
            .update(value)
            .digest('hex');
          console.log('Edge Lambda - Validating session for provider:', providerKey);
          //console.log('Edge Lambda - Expected signature:', expectedSignature, 'Got:', signature);
          if (signature === expectedSignature) {
            console.log('Edge Lambda - Session validated successfully for provider:', providerKey);
            return callback(null, request);
          } else {
            console.log('Edge Lambda - Session validation failed for provider:', providerKey);
          }
        } else {
          // Loop through providers if providerKey is not present
          console.log('Edge Lambda - No providerKey, trying all providers');
          for (const key of Object.keys(config)) {
            const provider = config[key];
            //console.log('Edge Lambda - Provider config for', key, ':', JSON.stringify(provider, null, 2));
            const expectedSignature = crypto
              .createHmac('sha256', provider.session_secret || '')
              .update(value)
              .digest('hex');
            //console.log(`Edge Lambda - Validating session for provider: ${key}, Expected signature: ${expectedSignature}, Got: ${signature}`);
            if (signature === expectedSignature) {
              console.log('Edge Lambda - Session validated successfully for provider:', key);
              return callback(null, request);
            }
          }
          console.log('Edge Lambda - Session validation failed for all providers');
        }
      }
    } else {
      console.log('Edge Lambda - No session cookie found');
    }

    // Redirect to OIDC if session is invalid or not present
    //console.log('Edge Lambda - Config:', JSON.stringify(config, null, 2));
    const defaultProviderKey = providerKey || Object.keys(config)[0];
    if (!defaultProviderKey || !config[defaultProviderKey]) {
      console.log('Edge Lambda - No matching provider for:', defaultProviderKey);
      return callback(null, {
        status: '403',
        statusDescription: 'Forbidden',
        body: 'No matching OIDC provider.',
      });
    }

    const provider = config[defaultProviderKey];
    const state = crypto.randomBytes(16).toString('hex');
    const loginUrl = `${provider.auth_url}?` +
      `client_id=${encodeURIComponent(provider.client_id)}` +
      `&redirect_uri=${encodeURIComponent(provider.redirect_uri)}` +
      `&response_type=code&scope=openid&state=${state}`;

    console.log('Edge Lambda - Redirecting to OIDC provider:', loginUrl);
    console.log('Edge Lambda - Setting state cookie:', state);

    return callback(null, {
      status: '302',
      statusDescription: 'Found',
      headers: {
        location: [{
          key: 'Location',
          value: loginUrl,
        }],
        'set-cookie': [{
          key: 'Set-Cookie',
          value: `state=${state}; Path=/; HttpOnly; Secure; SameSite=None; Max-Age=300`,
        }],
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
