import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateUserStatusDto {
  @IsBoolean()
  disabled!: boolean;
}

export class UpdateUserRoleDto {
  @IsBoolean()
  admin!: boolean;

  @IsOptional()
  claims?: Record<string, unknown>;
}
