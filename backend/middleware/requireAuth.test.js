import { requireAuth } from './requireAuth.js';

describe('requireAuth middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = { headers: {} };
    res = {
      status: function(code) { this.statusCode = code; return this; },
      json: function(data) { this.body = data; return this; }
    };
    next = () => { next.called = true; };
  });

  test('should reject when no authorization header', async () => {
    await requireAuth(req, res, next);
    
    expect(res.statusCode).toBe(401);
    expect(res.body.message).toBe('Missing or invalid Authorization header.');
    expect(next.called).toBeUndefined();
  });

  test('should reject invalid Bearer format', async () => {
    req.headers.authorization = 'InvalidFormat';
    
    await requireAuth(req, res, next);
    
    expect(res.statusCode).toBe(401);
    expect(res.body.message).toBe('Missing or invalid Authorization header.');
  });

  test('should reject when token is missing after Bearer', async () => {
    req.headers.authorization = 'Bearer ';
    
    await requireAuth(req, res, next);
    
    expect(res.statusCode).toBe(401);
    expect(res.body.message).toBe('Token missing.');
  });
});
