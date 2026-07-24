import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AdminUser } from '../types/admin-user';

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AdminUser => {
    const request = ctx.switchToHttp().getRequest<{ user: AdminUser }>();
    return request.user;
  }
);
