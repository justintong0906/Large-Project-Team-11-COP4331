import { requireAuth } from './requireAuth.js';

const mockRes = () => ({
  status(code) { this.statusCode = code; return this; },
  json(data) { this.body = data; return this; }
});

describe('requireAuth middleware', () => {
  test('rejects missing auth header', async () => {
    const res = mockRes();
    await requireAuth({ headers: {} }, res, () => {});
    expect(res.statusCode).toBe(401);
  });

  test('rejects header with improper JSON format', async () => {
    const res = mockRes();
    await requireAuth({ headers: { authorization: 'InvalidFormat' } }, res, () => {});
    expect(res.statusCode).toBe(401);
  });

  test('rejects header if no token token', async () => {
    const res = mockRes();
    await requireAuth({ headers: { authorization: 'Bearer ' } }, res, () => {});
    expect(res.statusCode).toBe(401);
  });
});
