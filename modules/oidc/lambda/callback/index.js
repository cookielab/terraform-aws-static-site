'use strict';

const https = require('https');
const querystring = require('querystring');
const crypto = require('crypto');

const configList = JSON.parse(process.env.OIDC_CONFIG_JSON || '[]');
const config = Object.fromEntries(configList.map(cfg => [cfg.application_name, cfg]));

exports.handler = (event, context, callback) => {
  //console.log('Callback Lambda - Received event:', JSON.stringify(event, null, 2));

  // API Gateway payload 2.0 format
  const query = event.queryStringParameters || {};
  const headers = event.headers || {};
  const cookies = event.cookies || [];
  const providerKey = query.auth;
  const code = query.code;
  const state = query.state;

  //console.log('Callback Lambda - Query params:', { providerKey, code, state });
  //console.log('Callback Lambda - Headers:', JSON.stringify(headers, null, 2));
  //console.log('Callback Lambda - Cookies from event.cookies:', cookies);

  if (!providerKey || !config[providerKey]) {
    console.log('Callback Lambda - No matching provider for:', providerKey);
    return callback(null, {
      statusCode: 403,
      body: 'No matching OIDC provider.',
    });
  }

  const provider = config[providerKey];

  if (!code || !state) {
    //console.log('Callback Lambda - Missing code or state:', { code, state });
    return callback(null, {
      statusCode: 400,
      body: 'Missing code or state.',
    });
  }

  // Validate cookie state
  let stateCookie = null;
  if (cookies.length > 0) {
    //console.log('Callback Lambda - Processing cookies:', cookies);
    const stateCookieEntry = cookies.find(c => c.startsWith('state='));
    if (stateCookieEntry) {
      stateCookie = stateCookieEntry.split('=')[1];
      //console.log('Callback Lambda - Found state cookie:', stateCookie);
    } else {
      //console.log('Callback Lambda - State cookie not found in:', cookies);
    }
  } else {
    console.log('Callback Lambda - No cookies present in event.cookies');
  }

  if (stateCookie !== state) {
    //console.log('Callback Lambda - State validation failed. Expected:', stateCookie, 'Got:', state);
    return callback(null, {
      statusCode: 400,
      body: 'Invalid state parameter.',
    });
  }

  console.log('Callback Lambda - State validation successful');

  // Exchange the authorization code for a token
  const tokenData = querystring.stringify({
    client_id: provider.client_id,
    client_secret: provider.client_secret,
    code,
    grant_type: 'authorization_code',
    redirect_uri: provider.redirect_uri,
  });

  const url = new URL(provider.token_url);
  const options = {
    hostname: url.hostname,
    path: url.pathname + url.search,
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(tokenData),
    },
  };

  console.log('Callback Lambda - Requesting token from:', provider.token_url);

  const tokenRequest = https.request(options, res => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        const json = JSON.parse(data);
        console.log('Callback Lambda - Token response:', json);
        if (json.error) {
          console.log('Callback Lambda - Token exchange failed:', json.error);
          return callback(null, {
            statusCode: 500,
            body: `Token exchange failed: ${json.error}`,
          });
        }

        // Create a session cookie
        const redirectUrl = new URL(provider.redirect_after_login);
        const cookieDomain = redirectUrl.hostname;
        const sessionValue = json.access_token;
        const signature = crypto
          .createHmac('sha256', provider.session_secret)
          .update(sessionValue)
          .digest('hex');
        const sessionCookie = `session=${sessionValue}.${signature}; Domain=${cookieDomain}; Path=/; HttpOnly; Secure; SameSite=None; Max-Age=${provider.session_duration}`;

        //console.log('Callback Lambda - Setting session cookie:', sessionCookie);
        return callback(null, {
          statusCode: 302,
          headers: {
            Location: provider.redirect_after_login,
            'Set-Cookie': sessionCookie,
          },
          body: '',
        });
      } catch (e) {
        console.log('Callback Lambda - Invalid token response:', e.message);
        return callback(null, {
          statusCode: 500,
          body: 'Invalid token response.',
        });
      }
    });
  });

  tokenRequest.on('error', err => {
    console.log('Callback Lambda - Token request failed:', err.message);
    return callback(null, {
      statusCode: 500,
      body: `Token request failed: ${err.message}`,
    });
  });

  tokenRequest.write(tokenData);
  tokenRequest.end();
};
