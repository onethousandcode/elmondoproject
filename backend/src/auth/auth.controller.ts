import { Controller, Post, Body, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const { email, password } = body;
    if (!email || !password) {
      throw new UnauthorizedException('Email and password are required');
    }
    return this.authService.login(email, password);
  }

  @Post('refresh')
  async refresh(@Body() body: { token: string }) {
    const { token } = body;
    if (!token) throw new UnauthorizedException('Refresh token required');
    return this.authService.refreshToken(token);
  }
}
