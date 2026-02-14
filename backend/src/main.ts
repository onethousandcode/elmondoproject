import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS for all origins (for testing)
  app.enableCors();

  // Or restrict to your Flutter web app
  // app.enableCors({ origin: 'http://localhost:5173' });

  await app.listen(process.env.PORT ?? 4000);
}
bootstrap();
