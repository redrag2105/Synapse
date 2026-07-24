import { ExecutionContext, UnauthorizedException, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { FirebaseAuthGuard } from '../src/common/guards/firebase-auth.guard';
import { AdminGuard } from '../src/common/guards/admin.guard';

function context(headers: Record<string, string>, user?: unknown): ExecutionContext {
  return {
    getHandler: () => ({}),
    getClass: () => ({}),
    switchToHttp: () => ({
      getRequest: () => ({ headers, user })
    })
  } as ExecutionContext;
}

describe('admin guards', () => {
  const reflector = { getAllAndOverride: jest.fn().mockReturnValue(false) } as unknown as Reflector;

  it('returns 401 when Authorization header is missing', async () => {
    const guard = new FirebaseAuthGuard({ auth: { verifyIdToken: jest.fn() } } as never, reflector);
    await expect(guard.canActivate(context({}))).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('returns 401 when token is invalid', async () => {
    const guard = new FirebaseAuthGuard({ auth: { verifyIdToken: jest.fn().mockRejectedValue(new Error('bad')) } } as never, reflector);
    await expect(guard.canActivate(context({ authorization: 'Bearer bad' }))).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('returns 403 when admin claim is missing', () => {
    const guard = new AdminGuard(reflector);
    expect(() => guard.canActivate(context({}, { uid: 'u1' }))).toThrow(ForbiddenException);
  });

  it('allows admin users', () => {
    const guard = new AdminGuard(reflector);
    expect(guard.canActivate(context({}, { uid: 'u1', admin: true }))).toBe(true);
  });
});
