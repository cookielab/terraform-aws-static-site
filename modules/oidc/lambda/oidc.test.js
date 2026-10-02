'use strict';

const assert = require('assert');
const crypto = require('crypto');
const { EventEmitter } = require('events');
const https = require('https');
const test = require('node:test');

const provider = {
  application_name: 'Engineer on Duty',
  client_id: 'client-id',
  client_secret: 'client-secret',
  auth_url: 'https://authentik.example/application/o/authorize/',
  token_url: 'https://authentik.example/application/o/token/',
  redirect_uri: 'https://eod.example/callback',
  redirect_after_login: 'https://eod.example',
  session_secret: 'test-session-secret',
  session_duration: 3600,
};

function loadHandler(path, config = [provider]) {
  process.env.OIDC_CONFIG_JSON = JSON.stringify(config);
  delete require.cache[require.resolve(path)];
  return require(path).handler;
}

function invoke(handler, event) {
  return new Promise((resolve, reject) => {
    handler(event, {}, (error, response) => error ? reject(error) : resolve(response));
  });
}

function edgeEvent({ querystring = '', cookie = '' } = {}) {
  const request = { querystring, headers: {} };
  if (cookie) request.headers.cookie = [{ key: 'Cookie', value: cookie }];
  return { Records: [{ cf: { request } }] };
}

function signedSession(payload) {
  const value = Buffer.from(JSON.stringify(payload)).toString('base64');
  const signature = crypto.createHmac('sha256', provider.session_secret).update(value).digest('hex');
  return `${value}.${signature}`;
}

function encodedState(name = provider.application_name) {
  return `state-value.${Buffer.from(name, 'utf8').toString('base64url')}`;
}

async function withTokenResponse(fn) {
  const original = https.request;
  https.request = (_options, callback) => {
    const req = new EventEmitter();
    req.write = () => {};
    req.end = () => {
      const res = new EventEmitter();
      callback(res);
      res.emit('data', JSON.stringify({ access_token: 'access-token' }));
      res.emit('end');
    };
    req.on = req.addListener.bind(req);
    return req;
  };
  try {
    return await fn();
  } finally {
    https.request = original;
  }
}

test('callback falls back to the only configured provider when provider cookies are absent', async () => {
  const handler = loadHandler('./callback/index.js');
  const state = 'plain-state';

  const response = await withTokenResponse(() => invoke(handler, {
    queryStringParameters: { code: 'code', state },
    cookies: [`state=${state}`],
  }));

  assert.equal(response.statusCode, 302);
  assert.equal(response.headers.Location, 'https://eod.example');
  assert.match(response.headers['Set-Cookie'], /^session=/);
});

test('callback resolves the provider encoded in state', async () => {
  const handler = loadHandler('./callback/index.js', [provider, { ...provider, application_name: 'Other App', client_id: 'other' }]);
  const state = encodedState();

  const response = await withTokenResponse(() => invoke(handler, {
    queryStringParameters: { code: 'code', state },
    cookies: [`state=${state}`],
  }));

  assert.equal(response.statusCode, 302);
  assert.match(response.headers['Set-Cookie'], /^session=/);
});

test('callback keeps state validation strict', async () => {
  const handler = loadHandler('./callback/index.js');

  const response = await invoke(handler, {
    queryStringParameters: { code: 'code', state: 'query-state' },
    cookies: ['state=cookie-state'],
  });

  assert.equal(response.statusCode, 400);
  assert.equal(response.body, 'Invalid state parameter.');
});

test('edge parses padded base64 session cookies without truncating the signature', async () => {
  const handler = loadHandler('./edge_auth/index.js');
  const session = signedSession({ access_token: 'token', exp: Date.now() + 60000 });
  assert.match(session, /=\./, 'test fixture must include base64 padding before the signature');

  const event = edgeEvent({ cookie: `session=${session}; auth_provider=${provider.application_name}` });
  const response = await invoke(handler, event);

  assert.strictEqual(response, event.Records[0].cf.request);
});

test('edge falls back from a stale provider cookie instead of returning 403', async () => {
  const handler = loadHandler('./edge_auth/index.js');

  const response = await invoke(handler, edgeEvent({ cookie: 'auth_provider=Deleted Provider' }));

  assert.equal(response.status, '302');
  assert.match(response.headers.location[0].value, /^https:\/\/authentik\.example\//);
  assert(response.headers['set-cookie'].some(cookie => cookie.value.includes('auth_provider=Engineer on Duty')));
});

test('edge redirects expired sessions instead of passing them through', async () => {
  const handler = loadHandler('./edge_auth/index.js');
  const session = signedSession({ access_token: 'token', exp: Date.now() - 1000 });

  const response = await invoke(handler, edgeEvent({ cookie: `session=${session}; auth_provider=${provider.application_name}` }));

  assert.equal(response.status, '302');
  assert.match(response.headers.location[0].value, /^https:\/\/authentik\.example\//);
});
