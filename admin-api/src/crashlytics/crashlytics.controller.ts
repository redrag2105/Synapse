import { Body, Controller, Get, Param, Patch } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrashlyticsService } from './crashlytics.service';

@ApiTags('crashlytics')
@ApiBearerAuth()
@Controller('admin/crashlytics')
export class CrashlyticsController {
  constructor(private readonly crashlytics: CrashlyticsService) {}

  @Get('issues')
  issues() {
    return this.crashlytics.issues();
  }

  @Get('issues/:issueId')
  issue(@Param('issueId') issueId: string) {
    return this.crashlytics.issue(issueId);
  }

  @Patch('issues/:issueId/status')
  updateStatus(@Param('issueId') issueId: string, @Body('status') status: string) {
    return this.crashlytics.updateStatus(issueId, status);
  }
}
