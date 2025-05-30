const https = require('https');
const querystring = require('querystring');
const jwt = require('jsonwebtoken');

const client_id = process.env.GITLAB_CLIENT_ID;
const client_secret = process.env.GITLAB_CLIENT_SECRET;
const redirect_uri = process.env.REDIRECT_URI;

function postToken(code) {
  const data = querystring.stringify({
    client_id,
    client_secret,
    code,
    grant_type: 'authorization_code',
    redirect_uri,
  });

  const options = {
    hostname: 'gitlab.com',
    path: '/oauth/token',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, res => {
      let body = '';
      res.on('data', chunk => (body += chunk));
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(body));
        } else {
          reject(new Error(`GitLab token error: ${body}`));
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

exports.handler = async (event) => {
  const code = event.queryStringParameters?.code;

  if (!code) {
    return {
      statusCode: 400,
      body: "Missing 'code' param"
    };
  }

  try {
    const tokenResponse = await postToken(code);
    const idToken = tokenResponse.id_token;

    const decoded = jwt.decode(idToken, { complete: true });

    // ⚠️ Optionally: ověřit signaturu (pro paranoidní verzi)
    if (!decoded) throw new Error("Invalid JWT");

    const cookie = `auth_token=${idToken}; Path=/; HttpOnly; Secure; Max-Age=3600; SameSite=Lax`;

    return {
      statusCode: 302,
      headers: {
        'Set-Cookie': cookie,
        'Location': '/' // přesměrování na hlavní appku
      },
    };

  } catch (err) {
    console.error('OAuth callback error:', err);
    return {
      statusCode: 500,
      body: 'OAuth callback failed'
    };
  }
};