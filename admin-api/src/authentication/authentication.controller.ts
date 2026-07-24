import { Controller, Get } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AdminUser } from '../common/types/admin-user';

@ApiTags('authentication')
@ApiBearerAuth()
@Controller('admin')
export class AuthenticationController {
  @Get('profile')
  profile(@CurrentUser() user: AdminUser) {
    return {
      uid: user.uid,
      email: user.email,
      name: user.name,
      picture: user.picture,
      admin: user.admin === true
    };
  }
}
