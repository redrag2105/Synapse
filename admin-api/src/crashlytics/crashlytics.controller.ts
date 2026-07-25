import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AdminUser } from '../common/types/admin-user';
import { CrashlyticsService } from './crashlytics.service';

@ApiTags('crashlytics')
@ApiBearerAuth()
@Controller('admin/crashlytics')
export class CrashlyticsController {
  constructor(private readonly crashlytics: CrashlyticsService) {}

  @Get('issues')
  issues(@Query('limit') limit = '50') {
    return this.crashlytics.issues(Number(limit) || 50);
  }

  @Get('issues/:issueId')
  issue(@Param('issueId') issueId: string) {
    return this.crashlytics.issue(issueId);
  }

  @Patch('issues/:issueId/status')
  updateStatus(
    @Param('issueId') issueId: string,
    @Body('status') status: string,
    @CurrentUser() user: AdminUser
  ) {
    return this.crashlytics.updateStatus(issueId, status, user);
  }
}
