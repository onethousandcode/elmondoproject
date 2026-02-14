import { Controller, Post, Body } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Post('register')
  async register(@Body() body: any) {
    const { name, email, password } = body;
    return this.usersService.create(name, email, password);
  }
}
