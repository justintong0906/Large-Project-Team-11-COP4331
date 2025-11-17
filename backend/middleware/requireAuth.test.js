import { requireAuth } from './requireAuth.js';

const mockRes = () => ({
  status(code) { this.statusCode = code; return this; },
  json(data) { this.body = data; return this; }
});

describe('requireAuth middleware', () => {
  test('should reject missing auth header', async () => {
    const res = mockRes();
    await requireAuth({ headers: {} }, res, () => {});
    expect(res.statusCode).toBe(401);
  });

  test('should reject invalid Bearer format', async () => {
    const res = mockRes();
    await requireAuth({ headers: { authorization: 'InvalidFormat' } }, res, () => {});
    expect(res.statusCode).toBe(401);
  });

  test('should reject empty token', async () => {
    const res = mockRes();
    await requireAuth({ headers: { authorization: 'Bearer ' } }, res, () => {});
    expect(res.statusCode).toBe(401);
  });
});
