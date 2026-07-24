import { IsArray, IsObject, IsOptional, IsString } from 'class-validator';

export class RemoteConfigTemplateDto {
  @IsObject()
  parameters!: Record<string, unknown>;

  @IsOptional()
  @IsArray()
  conditions?: unknown[];

  @IsOptional()
  @IsObject()
  parameterGroups?: Record<string, unknown>;

  @IsString()
  etag!: string;
}

export class RollbackDto {
  @IsString()
  versionNumber!: string;
}
