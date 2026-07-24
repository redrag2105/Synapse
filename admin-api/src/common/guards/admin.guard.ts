import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { AdminUser } from '../types/admin-user';

@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    if (this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass()
    ])) {
      return true;
    }

    const request = context.switchToHttp().getRequest<{ user?: AdminUser }>();
    if (request.user?.admin === true) return true;
    throw new ForbiddenException('Admin claim required');
  }
}
