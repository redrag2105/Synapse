import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';

@ApiTags('analytics')
@ApiBearerAuth()
@Controller('admin/analytics')
export class AnalyticsController {
  constructor(private readonly analytics: AnalyticsService) {}

  @Get('overview')
  overview(@Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    return this.analytics.overview(startDate, endDate);
  }

  @Get('events')
  events(@Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    return this.analytics.events(startDate, endDate);
  }

  @Get('top-topics')
  topTopics() {
    return this.analytics.topTopics();
  }

  @Get('top-publications')
  topPublications() {
    return this.analytics.topPublications();
  }
}
