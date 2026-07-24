import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request, Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  constructor(private readonly config: ConfigService) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;
    const payload = exception instanceof HttpException ? exception.getResponse() : undefined;
    const message = typeof payload === 'object' && payload && 'message' in payload
      ? (payload as { message: string | string[] }).message
      : status === 500
        ? 'Internal server error'
        : String(payload ?? 'Request failed');

    response.status(status).json({
      statusCode: status,
      code: this.codeFor(status),
      message: Array.isArray(message) ? 'Invalid request' : message,
      errors: Array.isArray(message) ? message : [],
      timestamp: new Date().toISOString(),
      path: request.url,
      ...(status === 500 && this.config.get<string>('nodeEnv') !== 'production'
        ? { detail: exception instanceof Error ? exception.message : undefined }
        : {})
    });
  }

  private codeFor(status: number) {
    if (status === 400) return 'VALIDATION_ERROR';
    if (status === 401) return 'UNAUTHORIZED';
    if (status === 403) return 'FORBIDDEN';
    if (status === 404) return 'NOT_FOUND';
    return status >= 500 ? 'INTERNAL_ERROR' : 'REQUEST_ERROR';
  }
}
