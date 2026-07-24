import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AdminUser } from '../common/types/admin-user';
import { SendNotificationDto } from './notifications.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@Controller('admin/notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get()
  list(@Query('limit') limit = '25') {
    return this.notifications.list(Number(limit) || 25);
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.notifications.get(id);
  }

  @Post('send')
  send(@Body() body: SendNotificationDto, @CurrentUser() user: AdminUser) {
    return this.notifications.send(body, user);
  }

  @Post('test')
  test(@Body() body: SendNotificationDto, @CurrentUser() user: AdminUser) {
    return this.notifications.send(body, user, true);
  }
}
