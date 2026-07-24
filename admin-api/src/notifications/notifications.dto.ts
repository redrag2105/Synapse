import { IsArray, IsIn, IsObject, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class SendNotificationDto {
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  title!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(500)
  body!: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsIn(['user', 'multiple_users', 'topic', 'all'])
  targetType!: 'user' | 'multiple_users' | 'topic' | 'all';

  @IsOptional()
  @IsString({ each: true })
  @IsArray()
  targetUsers?: string[];

  @IsOptional()
  @IsString()
  target?: string;

  @IsIn(['trending_topic', 'highly_cited_publication', 'research_trend_update', 'general'])
  type!: string;

  @IsOptional()
  @IsObject()
  data?: Record<string, unknown>;
}
