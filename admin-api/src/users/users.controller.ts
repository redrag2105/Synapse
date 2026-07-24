import { Body, Controller, Delete, Get, Param, Patch, Query, Req } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AdminUser } from '../common/types/admin-user';
import { UpdateUserRoleDto, UpdateUserStatusDto } from './users.dto';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth()
@Controller('admin/users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  list(@Query('limit') limit = '25', @Query('pageToken') pageToken?: string, @Query('search') search?: string) {
    return this.users.list(Number(limit) || 25, pageToken, search);
  }

  @Get(':uid')
  get(@Param('uid') uid: string) {
    return this.users.get(uid);
  }

  @Patch(':uid/status')
  setStatus(@Param('uid') uid: string, @Body() body: UpdateUserStatusDto, @CurrentUser() user: AdminUser, @Req() req: Request) {
    return this.users.setStatus(uid, body.disabled, user, req.ip);
  }

  @Patch(':uid/role')
  setRole(@Param('uid') uid: string, @Body() body: UpdateUserRoleDto, @CurrentUser() user: AdminUser, @Req() req: Request) {
    return this.users.setAdmin(uid, body.admin, user, req.ip);
  }

  @Delete(':uid')
  delete(@Param('uid') uid: string, @CurrentUser() user: AdminUser, @Req() req: Request) {
    return this.users.delete(uid, user, req.ip);
  }
}
