import { Body, Controller, Get, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AdminUser } from '../common/types/admin-user';
import { RemoteConfigTemplateDto, RollbackDto } from './remote-config.dto';
import { RemoteConfigService } from './remote-config.service';

@ApiTags('remote-config')
@ApiBearerAuth()
@Controller('admin/remote-config')
export class RemoteConfigController {
  constructor(private readonly remoteConfig: RemoteConfigService) {}

  @Get()
  getTemplate() {
    return this.remoteConfig.getTemplate();
  }

  @Post('validate')
  validate(@Body() body: RemoteConfigTemplateDto) {
    return this.remoteConfig.validate(body);
  }

  @Post('publish')
  publish(@Body() body: RemoteConfigTemplateDto, @CurrentUser() user: AdminUser) {
    return this.remoteConfig.publish(body, user);
  }

  @Get('versions')
  versions() {
    return this.remoteConfig.versions();
  }

  @Post('rollback')
  rollback(@Body() body: RollbackDto, @CurrentUser() user: AdminUser) {
    return this.remoteConfig.rollback(body.versionNumber, user);
  }
}
