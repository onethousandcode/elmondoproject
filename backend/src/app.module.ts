import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [
    // Load .env globally
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // Configure TypeORM asynchronously using ConfigService
    TypeOrmModule.forRootAsync({
  imports: [ConfigModule],
  inject: [ConfigService],
  useFactory: async (configService: ConfigService) => ({
    type: 'mysql' as const,
    host: configService.get<string>('DB_HOST', 'database'),
    port: parseInt(configService.get<string>('DB_PORT', '3306')),
    username: configService.get<string>('DB_USER', 'lms'),
    password: configService.get<string>('DB_PASSWORD', 'lms'),
    database: configService.get<string>('DB_NAME', 'lms'),
    autoLoadEntities: true,
    synchronize: true,
    retryAttempts: 10,       // Retry 10 times
    retryDelay: 3000,        // Wait 3 seconds between retries
  }),
}),


    UsersModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
