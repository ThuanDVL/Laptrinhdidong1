# Fellow4u API Design - 10+ Endpoints

## API Endpoints Overview

### 1. **Authentication APIs**
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `POST /auth/forgot-password` - Forgot password
- `POST /auth/verify-otp` - Verify OTP
- `POST /auth/reset-password` - Reset password

### 2. **User APIs**
- `GET /users/:id` - Get user profile
- `PUT /users/:id` - Update user profile
- `DELETE /users/:id` - Delete account
- `GET /users/:id/settings` - Get user settings
- `PUT /users/:id/settings` - Update user settings

### 3. **Tours/Trips APIs**
- `GET /tours` - Get all tours (with pagination, filters)
- `GET /tours/:id` - Get tour details
- `GET /tours/search` - Search tours
- `POST /tours` - Create new tour/trip
- `PUT /tours/:id` - Update tour
- `DELETE /tours/:id` - Delete tour

### 4. **Bookings APIs**
- `GET /bookings` - Get user's bookings
- `POST /bookings` - Create booking
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id` - Update booking
- `DELETE /bookings/:id` - Cancel booking

### 5. **Payments APIs**
- `POST /payments` - Create payment
- `GET /payments/:id` - Get payment details
- `POST /payments/:id/verify` - Verify payment
- `GET /payments/history` - Get payment history

### 6. **Notifications APIs**
- `GET /notifications` - Get user notifications
- `POST /notifications/:id/read` - Mark as read
- `DELETE /notifications/:id` - Delete notification
- `PUT /notifications/settings` - Update notification settings

### 7. **Messaging/Chat APIs**
- `GET /messages/:conversationId` - Get messages
- `POST /messages` - Send message
- `GET /conversations` - Get user conversations
- `POST /conversations` - Create conversation

### 8. **Favorites/Wishlist APIs**
- `GET /favorites` - Get favorites
- `POST /favorites` - Add to favorites
- `DELETE /favorites/:id` - Remove from favorites

### 9. **Additional APIs**
- `GET /home/feed` - Get home screen feed
- `GET /reviews/:tourId` - Get tour reviews
- `POST /reviews` - Post review
- `GET /categories` - Get tour categories
- `GET /trending` - Get trending tours

## Total: 40+ API Endpoints

## Response Format (Standard)
```json
{
  "success": true,
  "message": "Success message",
  "data": {},
  "statusCode": 200
}
```

## Error Response Format
```json
{
  "success": false,
  "message": "Error message",
  "statusCode": 400
}
```
