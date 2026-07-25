import { Controller, Delete, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AdminUser } from '../common/types/admin-user';
import { ReportsService } from './reports.service';

@ApiTags('reports')
@ApiBearerAuth()
@Controller('admin/reports')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}

  @Get()
  list(@Query('limit') limit = '50', @Query('pageToken') pageToken?: string, @Query('search') search?: string, @Query('uid') uid?: string) {
    return this.reports.list(Number(limit) || 50, pageToken, search, uid);
  }

  @Get('download-url')
  downloadUrl(@Query('path') path: string, @Query('inline') inline?: string) {
    return this.reports.signedUrl(path, inline === '1' || inline === 'true');
  }

  @Delete()
  delete(@Query('path') path: string, @CurrentUser() user: AdminUser) {
    return this.reports.delete(path, user);
  }
}
