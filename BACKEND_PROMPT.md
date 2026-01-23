# Backend Implementation Prompt for Pet Adoption App

## Overview
You're implementing backend API endpoints for a Flutter pet adoption app with real-time pet updates, user booking system, and admin dashboard management. The app has two main user roles: **Users** (who can view pets and make bookings) and **Admins** (who can manage pets and handle booking requests).

## Key Features to Implement

### 1. **Pets Management API** (Existing with enhancements)
Enhance existing pet endpoints to support filtering and real-time updates:

#### Endpoints:
- **GET /api/v1/items** 
  - Returns list of available pets
  - Query params: `page`, `limit`, `type`, `category`, `status`
  - Response includes: `postedBy` (user ID), `postedByName` (admin name), `createdAt`, `updatedAt`
  - **This endpoint should be optimized for dashboard refresh** - add timestamps and update tracking

- **GET /api/v1/items/:id**
  - Get single pet details
  - Include booking requests count for that pet (admin view only)

- **PUT /api/v1/items/:id** (Admin only)
  - Update pet details (breed, age, health status, location, etc.)
  - **CRITICAL**: When pet is updated by admin, return a webhook/event that frontend can listen to
  - Update `updatedAt` timestamp

- **DELETE /api/v1/items/:id** (Admin only)
  - Soft delete or mark as archived
  - Don't actually remove from database for records

### 2. **Bookings API** (NEW - Most Important)

#### Data Model:
```
Booking {
  _id: ObjectId,
  userId: String,         // User making booking
  userName: String,
  userEmail: String,
  userPhone: String,
  petId: String,          // Pet being booked
  petName: String,
  petImageUrl: String,
  status: 'pending|approved|rejected|cancelled',
  adminNotes: String,     // Notes from admin
  reason: String,         // Rejection reason
  createdAt: DateTime,
  approvedAt: DateTime,   // When approved by admin
  rejectedAt: DateTime,   // When rejected by admin
}
```

#### Endpoints:

**POST /api/v1/bookings/create**
- Create a new booking request
- Body: `{ userId, userName, userEmail, userPhone, petId, petName, petImageUrl }`
- Returns: Created booking object with status='pending'
- **Validation**: Check pet exists and is available
- Response: `{ status: 'created', data: bookingObject }`

**GET /api/v1/bookings/user/:userId**
- Get all bookings for a specific user
- Returns: Array of user's bookings (pending, approved, rejected)
- Used by: Users in their profile to see their booking history

**GET /api/v1/bookings/all** (Admin only)
- Get all bookings across all users
- Query params: `status` (optional: pending, approved, rejected, cancelled)
- Used by: Admin dashboard to manage all bookings
- **CRITICAL**: Should refresh quickly for real-time dashboard
- Sort by: `createdAt` descending (newest first)
- Returns: `{ status: 'success', data: [ bookings ] }`

**GET /api/v1/bookings/pet/:petId** (Admin only)
- Get all booking requests for a specific pet
- Returns: Array of bookings for that pet
- Used by: Admin to see who requested which pet

**PUT /api/v1/bookings/:bookingId/approve** (Admin only)
- Approve a booking request
- Body: `{ status: 'approved', adminNotes: String?, approvedAt: DateTime }`
- Updates: `status`, `adminNotes`, `approvedAt`
- Returns: Updated booking object
- Optional: Mark pet as adopted or in process

**PUT /api/v1/bookings/:bookingId/reject** (Admin only)
- Reject a booking request
- Body: `{ status: 'rejected', reason: String?, adminNotes: String?, rejectedAt: DateTime }`
- Updates: `status`, `reason`, `adminNotes`, `rejectedAt`
- Returns: Updated booking object

**PUT /api/v1/bookings/:bookingId/cancel** (User or Admin)
- Cancel a booking (user cancels their own or admin cancels)
- Body: `{ status: 'cancelled' }`
- Updates: `status`
- Returns: Updated booking object

### 3. **Admin Pet Dashboard - Key Requirements**

The frontend filters pets to show only those posted/updated by admin:
- Filter condition: `postedBy === 'admin'` OR `postedByName === 'admin'`
- **Important**: Make sure when an admin creates/updates a pet, it's properly marked with admin user ID

#### Endpoint Enhancement Needed:
- **POST /api/v1/items** (Create pet) - Ensure `postedBy` is set to admin's ID
- **PUT /api/v1/items/:id** - When admin updates, ensure timestamps reflect this

### 4. **Real-Time Updates Strategy** (Optional but Recommended)

For real-time pet updates to reflect on user dashboard without manual refresh:

**Option A: Polling (Simpler)**
- Frontend polls `/api/v1/items` every 5-10 seconds
- Use `updatedAt` timestamp to detect changes
- Frontend will auto-refresh when new items detected

**Option B: WebSocket (Advanced)**
- Implement Socket.io or WebSocket server
- Emit events when:
  - Pet is created: `pet:created`
  - Pet is updated: `pet:updated`
  - Booking status changes: `booking:statusChanged`
- Frontend listens and updates UI in real-time

### 5. **Database Schema Updates**

If using MongoDB:

```javascript
// Pets Collection
db.items.updateMany(
  {},
  {
    $set: {
      postedBy: "admin_id_here",
      postedByName: "Admin",
      updatedAt: new Date(),
    }
  }
)

// Create new Bookings Collection
db.createCollection("bookings", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "petId", "status", "createdAt"],
      properties: {
        _id: { bsonType: "objectId" },
        userId: { bsonType: "string" },
        userName: { bsonType: "string" },
        userEmail: { bsonType: "string" },
        userPhone: { bsonType: "string" },
        petId: { bsonType: "string" },
        petName: { bsonType: "string" },
        petImageUrl: { bsonType: "string" },
        status: { enum: ["pending", "approved", "rejected", "cancelled"] },
        adminNotes: { bsonType: "string" },
        reason: { bsonType: "string" },
        createdAt: { bsonType: "date" },
        approvedAt: { bsonType: "date" },
        rejectedAt: { bsonType: "date" }
      }
    }
  }
})

// Create indexes
db.bookings.createIndex({ "userId": 1 })
db.bookings.createIndex({ "petId": 1 })
db.bookings.createIndex({ "status": 1 })
db.bookings.createIndex({ "createdAt": -1 })
```

### 6. **Error Handling**
Ensure proper error responses:
```json
{
  "status": "error",
  "message": "Descriptive error message",
  "code": "ERROR_CODE"
}
```

Common errors to handle:
- Pet not found
- User not found
- Booking already exists for user+pet
- Invalid status transition
- Unauthorized access (admin-only routes)

### 7. **Authentication**
- All endpoints except `/auth/login` and `/auth/register` require JWT token
- Admin endpoints require additional `role === 'admin'` check
- Pass token in header: `Authorization: Bearer <token>`

### 8. **Response Format**
All responses should follow:
```json
{
  "status": "success|error",
  "data": { /* response data */ },
  "message": "Optional message"
}
```

## Frontend Flow to Validate

1. **User Dashboard**:
   - GET `/api/v1/items` → Display all pets
   - Auto-refresh every 5 seconds (or use WebSocket)
   - Admin-updated pets should appear in real-time

2. **Pet Details Screen**:
   - GET `/api/v1/items/:id` → Show pet details
   - User clicks "Book This Pet" → POST `/api/v1/bookings/create`

3. **User Profile/Bookings**:
   - GET `/api/v1/bookings/user/:userId` → Show user's booking history

4. **Admin Dashboard**:
   - GET `/api/v1/bookings/all` → Show all booking requests
   - GET `/api/v1/items?filter=admin` → Show admin pets
   - PUT `/api/v1/bookings/:id/approve` or `/reject` → Handle bookings
   - PUT `/api/v1/items/:id` → Update pet, auto-refresh user dashboards

## Summary of API Endpoints Required

| Method | Endpoint | Role | Purpose |
|--------|----------|------|---------|
| POST | `/api/v1/bookings/create` | User | Create booking |
| GET | `/api/v1/bookings/user/:userId` | User | Get user bookings |
| GET | `/api/v1/bookings/all` | Admin | Get all bookings |
| GET | `/api/v1/bookings/pet/:petId` | Admin | Get pet bookings |
| PUT | `/api/v1/bookings/:id/approve` | Admin | Approve booking |
| PUT | `/api/v1/bookings/:id/reject` | Admin | Reject booking |
| PUT | `/api/v1/bookings/:id/cancel` | User/Admin | Cancel booking |
| GET | `/api/v1/items` | Public | List pets (enhanced) |
| GET | `/api/v1/items/:id` | Public | Get pet details |
| PUT | `/api/v1/items/:id` | Admin | Update pet |
| DELETE | `/api/v1/items/:id` | Admin | Delete pet |

---

## Test Cases to Verify

1. User creates booking → Booking shows as pending
2. Admin approves booking → User sees approved status
3. Admin updates pet → All user dashboards refresh and show updated pet
4. Admin creates new pet → Pet appears on user dashboard immediately
5. Admin rejects booking → Reason is saved and user can see it
