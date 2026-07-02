
window.onload = function() {
  // Build a system
  var url = window.location.search.match(/url=([^&]+)/);
  if (url && url.length > 1) {
    url = decodeURIComponent(url[1]);
  } else {
    url = window.location.origin;
  }
  var options = {
  "swaggerDoc": {
    "openapi": "3.0.0",
    "info": {
      "title": "Parking Building Management System API",
      "version": "1.0.0",
      "description": "\n## Hệ thống quản lý tòa nhà gửi xe\n\n### Authentication\nSử dụng Bearer Token (JWT) để xác thực.\nĐăng nhập để lấy accessToken, sau đó thêm vào header:\n`Authorization: Bearer <accessToken>`\n\n### Roles\n- **system_admin**: Quản trị viên hệ thống\n- **parking_manager**: Quản lý bãi xe  \n- **parking_staff**: Nhân viên bãi xe\n- **parking_user**: Người dùng / Tài xế\n      ",
      "contact": {
        "name": "API Support",
        "email": "support@parking.com"
      }
    },
    "servers": [
      {
        "url": "http://localhost:5000/api/v1",
        "description": "Development Server"
      },
      {
        "url": "https://web-production-a1e70.up.railway.app/api/v1",
        "description": "Production Server"
      }
    ],
    "components": {
      "securitySchemes": {
        "BearerAuth": {
          "type": "http",
          "scheme": "bearer",
          "bearerFormat": "JWT",
          "description": "Enter JWT token"
        }
      },
      "schemas": {
        "Error": {
          "type": "object",
          "properties": {
            "success": {
              "type": "boolean",
              "example": false
            },
            "message": {
              "type": "string"
            },
            "errors": {
              "type": "array",
              "items": {
                "type": "object"
              }
            }
          }
        },
        "Pagination": {
          "type": "object",
          "properties": {
            "total": {
              "type": "integer"
            },
            "page": {
              "type": "integer"
            },
            "limit": {
              "type": "integer"
            },
            "totalPages": {
              "type": "integer"
            },
            "hasNextPage": {
              "type": "boolean"
            },
            "hasPrevPage": {
              "type": "boolean"
            }
          }
        }
      }
    },
    "security": [
      {
        "BearerAuth": []
      }
    ],
    "tags": [
      {
        "name": "Auth",
        "description": "Authentication & Authorization"
      },
      {
        "name": "Users",
        "description": "User Management"
      },
      {
        "name": "Parking Lots",
        "description": "Parking Building Management"
      },
      {
        "name": "Floors",
        "description": "Floor Management"
      },
      {
        "name": "Zones",
        "description": "Zone Management"
      },
      {
        "name": "Vehicle Types",
        "description": "Vehicle Type Management"
      },
      {
        "name": "Parking Slots",
        "description": "Parking Slot Management"
      },
      {
        "name": "Bookings",
        "description": "Booking / Reservation"
      },
      {
        "name": "Parking Sessions",
        "description": "Entry/Exit Management"
      },
      {
        "name": "Payments",
        "description": "Payment System"
      },
      {
        "name": "Reports",
        "description": "Reports & Analytics"
      },
      {
        "name": "Dashboard",
        "description": "Dashboard Statistics"
      },
      {
        "name": "Notifications",
        "description": "Notification System"
      },
      {
        "name": "Feedbacks",
        "description": "Feedback System"
      },
      {
        "name": "Incidents",
        "description": "Incident Management"
      },
      {
        "name": "LPR",
        "description": "AI License Plate Recognition (OCR)"
      },
      {
        "name": "Vehicles",
        "description": "User vehicle management"
      }
    ],
    "paths": {
      "/auth/register": {
        "post": {
          "summary": "Register a new user",
          "tags": [
            "Auth"
          ],
          "security": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "fullName",
                    "email",
                    "password"
                  ],
                  "properties": {
                    "fullName": {
                      "type": "string",
                      "example": "Nguyen Van A"
                    },
                    "email": {
                      "type": "string",
                      "example": "user@example.com"
                    },
                    "password": {
                      "type": "string",
                      "example": "Password123"
                    },
                    "phone": {
                      "type": "string",
                      "example": "0912345678"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Registration successful"
            },
            "409": {
              "description": "Email already exists"
            },
            "422": {
              "description": "Validation error"
            }
          }
        }
      },
      "/auth/login": {
        "post": {
          "summary": "Login with email and password",
          "tags": [
            "Auth"
          ],
          "security": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "email",
                    "password"
                  ],
                  "properties": {
                    "email": {
                      "type": "string",
                      "example": "admin@parking.com"
                    },
                    "password": {
                      "type": "string",
                      "example": "Admin123!"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Login successful, returns accessToken and refreshToken"
            },
            "401": {
              "description": "Invalid credentials"
            },
            "403": {
              "description": "Account blocked or not verified"
            }
          }
        }
      },
      "/auth/logout": {
        "post": {
          "summary": "Logout and invalidate refresh token",
          "tags": [
            "Auth"
          ],
          "responses": {
            "200": {
              "description": "Logged out successfully"
            }
          }
        }
      },
      "/auth/refresh-token": {
        "post": {
          "summary": "Refresh access token using refresh token",
          "tags": [
            "Auth"
          ],
          "security": [],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "refreshToken": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "New tokens issued"
            },
            "401": {
              "description": "Invalid or expired refresh token"
            }
          }
        }
      },
      "/auth/verify-email/{token}": {
        "get": {
          "summary": "Verify email address",
          "tags": [
            "Auth"
          ],
          "security": [],
          "parameters": [
            {
              "in": "path",
              "name": "token",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Email verified successfully"
            },
            "400": {
              "description": "Invalid or expired token"
            }
          }
        }
      },
      "/auth/resend-verification": {
        "post": {
          "summary": "Resend email verification",
          "tags": [
            "Auth"
          ],
          "security": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "email": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Verification email sent"
            }
          }
        }
      },
      "/auth/forgot-password": {
        "post": {
          "summary": "Request password reset email",
          "tags": [
            "Auth"
          ],
          "security": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "email"
                  ],
                  "properties": {
                    "email": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Reset email sent if email is registered"
            }
          }
        }
      },
      "/auth/reset-password/{token}": {
        "post": {
          "summary": "Reset password with token",
          "tags": [
            "Auth"
          ],
          "security": [],
          "parameters": [
            {
              "in": "path",
              "name": "token",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "password",
                    "confirmPassword"
                  ],
                  "properties": {
                    "password": {
                      "type": "string"
                    },
                    "confirmPassword": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Password reset successfully"
            },
            "400": {
              "description": "Invalid or expired token"
            }
          }
        }
      },
      "/auth/change-password": {
        "post": {
          "summary": "Change password (authenticated)",
          "tags": [
            "Auth"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "currentPassword",
                    "newPassword"
                  ],
                  "properties": {
                    "currentPassword": {
                      "type": "string"
                    },
                    "newPassword": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Password changed successfully"
            },
            "400": {
              "description": "Current password incorrect"
            }
          }
        }
      },
      "/auth/me": {
        "get": {
          "summary": "Get current authenticated user profile",
          "tags": [
            "Auth"
          ],
          "responses": {
            "200": {
              "description": "User profile data"
            },
            "401": {
              "description": "Not authenticated"
            }
          }
        }
      },
      "/bookings/my": {
        "get": {
          "summary": "Get my bookings",
          "tags": [
            "Bookings"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "pending",
                  "approved",
                  "cancelled",
                  "completed"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "My bookings list"
            }
          }
        }
      },
      "/bookings": {
        "get": {
          "summary": "Get all bookings (staff/admin)",
          "tags": [
            "Bookings"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "parkingLot",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "startDate",
              "schema": {
                "type": "string",
                "format": "date"
              }
            },
            {
              "in": "query",
              "name": "endDate",
              "schema": {
                "type": "string",
                "format": "date"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Paginated booking list"
            }
          }
        },
        "post": {
          "summary": "Create a booking",
          "tags": [
            "Bookings"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "parkingLot",
                    "vehicleType",
                    "scheduledDate",
                    "startTime",
                    "endTime",
                    "vehicleInfo"
                  ],
                  "properties": {
                    "parkingLot": {
                      "type": "string"
                    },
                    "vehicleType": {
                      "type": "string"
                    },
                    "scheduledDate": {
                      "type": "string",
                      "format": "date",
                      "example": "2024-12-25"
                    },
                    "startTime": {
                      "type": "string",
                      "example": "08:00"
                    },
                    "endTime": {
                      "type": "string",
                      "example": "17:00"
                    },
                    "vehicleInfo": {
                      "type": "object",
                      "properties": {
                        "licensePlate": {
                          "type": "string",
                          "example": "51A-12345"
                        },
                        "vehicleModel": {
                          "type": "string"
                        },
                        "vehicleColor": {
                          "type": "string"
                        }
                      }
                    },
                    "floorId": {
                      "type": "string"
                    },
                    "zoneId": {
                      "type": "string"
                    },
                    "notes": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Booking created with QR code"
            }
          }
        }
      },
      "/bookings/{id}": {
        "get": {
          "summary": "Get booking by ID",
          "tags": [
            "Bookings"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Booking data with QR code"
            }
          }
        }
      },
      "/bookings/{id}/approve": {
        "patch": {
          "summary": "Approve a booking (staff/manager)",
          "tags": [
            "Bookings"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Booking approved"
            }
          }
        }
      },
      "/bookings/{id}/cancel": {
        "patch": {
          "summary": "Cancel a booking",
          "tags": [
            "Bookings"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "reason": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Booking cancelled"
            }
          }
        }
      },
      "/feedbacks": {
        "get": {
          "summary": "Get feedbacks",
          "tags": [
            "Feedbacks"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "type",
              "schema": {
                "type": "string",
                "enum": [
                  "general",
                  "complaint",
                  "suggestion",
                  "issue_report",
                  "compliment"
                ]
              }
            },
            {
              "in": "query",
              "name": "rating",
              "schema": {
                "type": "integer",
                "minimum": 1,
                "maximum": 5
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Feedback list"
            }
          }
        },
        "post": {
          "summary": "Submit feedback",
          "tags": [
            "Feedbacks"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "parkingLot",
                    "rating",
                    "title",
                    "content"
                  ],
                  "properties": {
                    "parkingLot": {
                      "type": "string"
                    },
                    "rating": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 5
                    },
                    "title": {
                      "type": "string"
                    },
                    "content": {
                      "type": "string"
                    },
                    "type": {
                      "type": "string",
                      "enum": [
                        "general",
                        "complaint",
                        "suggestion",
                        "issue_report",
                        "compliment"
                      ]
                    },
                    "parkingSession": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Feedback submitted"
            }
          }
        }
      },
      "/feedbacks/{id}/respond": {
        "patch": {
          "summary": "Respond to feedback (manager)",
          "tags": [
            "Feedbacks"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "response"
                  ],
                  "properties": {
                    "response": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Response recorded"
            }
          }
        }
      },
      "/floors": {
        "get": {
          "summary": "Get all floors",
          "tags": [
            "Floors"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLot",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "active",
                  "inactive",
                  "maintenance"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Floor list"
            }
          }
        },
        "post": {
          "summary": "Create a floor",
          "tags": [
            "Floors"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "parkingLot",
                    "floorNumber",
                    "name"
                  ],
                  "properties": {
                    "parkingLot": {
                      "type": "string"
                    },
                    "floorNumber": {
                      "type": "integer",
                      "example": 1
                    },
                    "name": {
                      "type": "string",
                      "example": "Tầng 1"
                    },
                    "floorType": {
                      "type": "string",
                      "enum": [
                        "ground",
                        "above_ground",
                        "basement"
                      ]
                    },
                    "allowedVehicleTypes": {
                      "type": "array",
                      "items": {
                        "type": "string"
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Floor created"
            }
          }
        }
      },
      "/incidents": {
        "get": {
          "summary": "Get all incidents",
          "tags": [
            "Incidents"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "open",
                  "in_progress",
                  "resolved",
                  "closed",
                  "escalated"
                ]
              }
            },
            {
              "in": "query",
              "name": "type",
              "schema": {
                "type": "string",
                "enum": [
                  "lost_ticket",
                  "wrong_license_plate",
                  "overdue",
                  "wrong_zone",
                  "slot_occupied",
                  "slot_damaged",
                  "vehicle_damage",
                  "theft",
                  "other"
                ]
              }
            },
            {
              "in": "query",
              "name": "severity",
              "schema": {
                "type": "string",
                "enum": [
                  "low",
                  "medium",
                  "high",
                  "critical"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Incident list"
            }
          }
        },
        "post": {
          "summary": "Report an incident",
          "tags": [
            "Incidents"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "parkingLot",
                    "type",
                    "title",
                    "description"
                  ],
                  "properties": {
                    "parkingLot": {
                      "type": "string"
                    },
                    "type": {
                      "type": "string"
                    },
                    "title": {
                      "type": "string"
                    },
                    "description": {
                      "type": "string"
                    },
                    "severity": {
                      "type": "string",
                      "enum": [
                        "low",
                        "medium",
                        "high",
                        "critical"
                      ]
                    },
                    "parkingSession": {
                      "type": "string"
                    },
                    "slot": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Incident reported"
            }
          }
        }
      },
      "/incidents/{id}/resolve": {
        "patch": {
          "summary": "Resolve an incident",
          "tags": [
            "Incidents"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "description": {
                      "type": "string"
                    },
                    "extraCharge": {
                      "type": "number"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Incident resolved"
            }
          }
        }
      },
      "/lpr/recognize": {
        "post": {
          "summary": "Recognize license plate from camera image",
          "description": "Upload a camera-captured image to extract the license plate using AI/OCR.\nSupports two input methods:\n- **Multipart**: Send image as form-data field \"image\"\n- **Base64**: Send JSON body with \"imageBase64\" field\n\nUses Plate Recognizer API (if configured) with Tesseract.js fallback.\n",
          "tags": [
            "LPR"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "image": {
                      "type": "string",
                      "format": "binary",
                      "description": "Camera-captured image file"
                    }
                  }
                }
              },
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "imageBase64": {
                      "type": "string",
                      "description": "Base64 encoded image (data URI or raw base64)"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "License plate recognized successfully",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "success": {
                        "type": "boolean",
                        "example": true
                      },
                      "message": {
                        "type": "string",
                        "example": "License plate recognized."
                      },
                      "data": {
                        "type": "object",
                        "properties": {
                          "licensePlate": {
                            "type": "string",
                            "example": "30A-12345"
                          },
                          "confidence": {
                            "type": "number",
                            "example": 92
                          },
                          "engine": {
                            "type": "string",
                            "enum": [
                              "tesseract",
                              "plate_recognizer"
                            ]
                          },
                          "processingTimeMs": {
                            "type": "number",
                            "example": 1250
                          },
                          "candidates": {
                            "type": "array",
                            "items": {
                              "type": "object",
                              "properties": {
                                "plate": {
                                  "type": "string"
                                },
                                "confidence": {
                                  "type": "number"
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            "400": {
              "description": "No image provided"
            },
            "401": {
              "description": "Authentication required"
            },
            "403": {
              "description": "Insufficient permissions"
            }
          }
        }
      },
      "/notifications": {
        "get": {
          "summary": "Get my notifications",
          "tags": [
            "Notifications"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "unreadOnly",
              "schema": {
                "type": "boolean"
              }
            },
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Notification list"
            }
          }
        }
      },
      "/parking-lots": {
        "get": {
          "summary": "Get all parking lots",
          "tags": [
            "Parking Lots"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              }
            },
            {
              "in": "query",
              "name": "search",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "active",
                  "inactive",
                  "maintenance",
                  "closed"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of parking lots"
            }
          }
        },
        "post": {
          "summary": "Create parking lot (admin only)",
          "tags": [
            "Parking Lots"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name",
                    "code",
                    "address"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "example": "Bãi Xe Tòa Nhà Vincom"
                    },
                    "code": {
                      "type": "string",
                      "example": "VCBP01"
                    },
                    "address": {
                      "type": "object",
                      "properties": {
                        "street": {
                          "type": "string"
                        },
                        "district": {
                          "type": "string"
                        },
                        "city": {
                          "type": "string"
                        }
                      }
                    },
                    "manager": {
                      "type": "string",
                      "description": "ObjectId of a user with role parking_manager"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Parking lot created"
            },
            "400": {
              "description": "Invalid manager role"
            },
            "409": {
              "description": "Code already exists"
            }
          }
        }
      },
      "/parking-lots/available-staff": {
        "get": {
          "summary": "Get unassigned staff (manager/admin)",
          "tags": [
            "Parking Lots - Staff Assignment"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "search",
              "schema": {
                "type": "string"
              },
              "description": "Search by name, email or phone"
            }
          ],
          "responses": {
            "200": {
              "description": "List of available staff"
            }
          }
        }
      },
      "/parking-lots/{id}": {
        "get": {
          "summary": "Get parking lot by ID",
          "tags": [
            "Parking Lots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Parking lot data"
            }
          }
        },
        "put": {
          "summary": "Update parking lot",
          "tags": [
            "Parking Lots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Updated"
            }
          }
        },
        "delete": {
          "summary": "Delete parking lot (admin)",
          "tags": [
            "Parking Lots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Deleted"
            }
          }
        }
      },
      "/parking-lots/{id}/staff": {
        "get": {
          "summary": "Get staff assigned to a parking lot",
          "tags": [
            "Parking Lots - Staff Assignment"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Parking lot ID"
            }
          ],
          "responses": {
            "200": {
              "description": "List of assigned staff"
            }
          }
        },
        "post": {
          "summary": "Assign staff to a parking lot",
          "tags": [
            "Parking Lots - Staff Assignment"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "staffId"
                  ],
                  "properties": {
                    "staffId": {
                      "type": "string",
                      "description": "User ID of the staff member",
                      "example": "60d5ec49f1b2c72b9c8e4d3a"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Staff assigned"
            },
            "409": {
              "description": "Staff already assigned"
            }
          }
        }
      },
      "/parking-lots/{id}/staff/{staffId}": {
        "delete": {
          "summary": "Remove staff from a parking lot",
          "tags": [
            "Parking Lots - Staff Assignment"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Parking lot ID"
            },
            {
              "in": "path",
              "name": "staffId",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Staff user ID"
            }
          ],
          "responses": {
            "200": {
              "description": "Staff removed"
            },
            "404": {
              "description": "Staff not found in this lot"
            }
          }
        }
      },
      "/parking-sessions": {
        "get": {
          "summary": "Get all parking sessions",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "active",
                  "completed",
                  "cancelled"
                ]
              }
            },
            {
              "in": "query",
              "name": "licensePlate",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "parkingLot",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "startDate",
              "schema": {
                "type": "string",
                "format": "date"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Paginated session list"
            }
          }
        }
      },
      "/parking-sessions/find-active": {
        "get": {
          "summary": "Find active session by license plate or session code",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "licensePlate",
              "schema": {
                "type": "string"
              },
              "example": "51A-12345"
            },
            {
              "in": "query",
              "name": "sessionCode",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "parkingLotId",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Active session data"
            },
            "404": {
              "description": "No active session found"
            }
          }
        }
      },
      "/parking-sessions/overdue": {
        "get": {
          "summary": "Get overdue sessions",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLotId",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of overdue sessions"
            }
          }
        }
      },
      "/parking-sessions/check-in": {
        "post": {
          "summary": "Check-in a vehicle (staff)",
          "tags": [
            "Parking Sessions"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "parkingLotId"
                  ],
                  "properties": {
                    "bookingId": {
                      "type": "string",
                      "description": "Provide for booking-based check-in"
                    },
                    "monthlyPassCode": {
                      "type": "string",
                      "description": "Provide for monthly pass QR-based check-in"
                    },
                    "licensePlate": {
                      "type": "string",
                      "example": "51A-12345"
                    },
                    "vehicleTypeId": {
                      "type": "string",
                      "description": "Required for walk-in check-in"
                    },
                    "parkingLotId": {
                      "type": "string"
                    },
                    "slotId": {
                      "type": "string",
                      "description": "Optional, auto-assigned if not provided"
                    },
                    "vehicleModel": {
                      "type": "string"
                    },
                    "vehicleColor": {
                      "type": "string"
                    },
                    "ticketNumber": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Session created, slot assigned"
            }
          }
        }
      },
      "/parking-sessions/{id}": {
        "get": {
          "summary": "Get session by ID",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Session details with fee breakdown"
            }
          }
        }
      },
      "/parking-sessions/{id}/check-out": {
        "patch": {
          "summary": "Check-out a vehicle and calculate fee (staff)",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Session completed with fee breakdown"
            }
          }
        }
      },
      "/parking-sessions/{id}/evidence": {
        "post": {
          "summary": "Upload evidence images (entry/exit photos)",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "images": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "format": "binary"
                      }
                    },
                    "type": {
                      "type": "string",
                      "enum": [
                        "entry",
                        "exit",
                        "incident"
                      ]
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Images uploaded"
            }
          }
        }
      },
      "/parking-sessions/{id}/license-plate": {
        "patch": {
          "summary": "Update license plate of an active session (staff)",
          "tags": [
            "Parking Sessions"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "licensePlate"
                  ],
                  "properties": {
                    "licensePlate": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "License plate updated successfully"
            }
          }
        }
      },
      "/parking-slots": {
        "get": {
          "summary": "Get all parking slots with filters",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLot",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "floor",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "zone",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "vehicleType",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "available",
                  "occupied",
                  "reserved",
                  "maintenance",
                  "locked"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Paginated slot list"
            }
          }
        },
        "post": {
          "summary": "Create a new parking slot",
          "tags": [
            "Parking Slots"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "slotCode",
                    "parkingLot",
                    "floor",
                    "zone",
                    "vehicleType"
                  ],
                  "properties": {
                    "slotCode": {
                      "type": "string",
                      "example": "A-001"
                    },
                    "parkingLot": {
                      "type": "string"
                    },
                    "floor": {
                      "type": "string"
                    },
                    "zone": {
                      "type": "string"
                    },
                    "vehicleType": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Slot created"
            }
          }
        }
      },
      "/parking-slots/available": {
        "get": {
          "summary": "Find available slots (AI-powered optimal suggestion)",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLotId",
              "required": true,
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "vehicleTypeId",
              "required": true,
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "floorId",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "zoneId",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Available slots with recommended slot"
            }
          }
        }
      },
      "/parking-slots/floor-map/{floorId}": {
        "get": {
          "summary": "Get realtime slot map for a floor",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "floorId",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Floor slot map"
            }
          }
        }
      },
      "/parking-slots/{id}": {
        "get": {
          "summary": "Get slot by ID",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Slot data"
            }
          }
        },
        "put": {
          "summary": "Update slot",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Updated slot"
            }
          }
        },
        "delete": {
          "summary": "Delete slot",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Slot deleted"
            }
          }
        }
      },
      "/parking-slots/{id}/status": {
        "patch": {
          "summary": "Update slot status (realtime)",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "status"
                  ],
                  "properties": {
                    "status": {
                      "type": "string",
                      "enum": [
                        "available",
                        "occupied",
                        "reserved",
                        "maintenance",
                        "locked"
                      ]
                    },
                    "notes": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Status updated and emitted via Socket.IO"
            }
          }
        }
      },
      "/parking-slots/{id}/lock": {
        "post": {
          "summary": "Temporarily lock a slot for 3 minutes while user is selecting",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Slot locked with lockedUntil timestamp"
            },
            "409": {
              "description": "Slot already locked by another user"
            }
          }
        }
      },
      "/parking-slots/{id}/unlock": {
        "delete": {
          "summary": "Release a slot lock",
          "tags": [
            "Parking Slots"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Slot unlocked"
            }
          }
        }
      },
      "/payments/sepay-webhook": {
        "post": {
          "summary": "SEPay webhook callback (public endpoint)",
          "description": "Called by SEPay when a bank transfer is received.\nMatches transfer content (PAR code) to confirm pending payments.\nNo authentication required.\n",
          "tags": [
            "Payments"
          ],
          "security": [],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "number"
                    },
                    "gateway": {
                      "type": "string",
                      "example": "MBBank"
                    },
                    "transactionDate": {
                      "type": "string"
                    },
                    "accountNumber": {
                      "type": "string"
                    },
                    "content": {
                      "type": "string",
                      "example": "PAR1606A3B2C1"
                    },
                    "transferType": {
                      "type": "string",
                      "enum": [
                        "in",
                        "out"
                      ]
                    },
                    "transferAmount": {
                      "type": "number"
                    },
                    "referenceCode": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Webhook processed"
            }
          }
        }
      },
      "/payments": {
        "get": {
          "summary": "Get all payments",
          "tags": [
            "Payments"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "pending",
                  "completed",
                  "failed",
                  "refunded"
                ]
              }
            },
            {
              "in": "query",
              "name": "method",
              "schema": {
                "type": "string",
                "enum": [
                  "cash",
                  "momo",
                  "vnpay",
                  "bank_transfer"
                ]
              }
            },
            {
              "in": "query",
              "name": "startDate",
              "schema": {
                "type": "string",
                "format": "date"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Paginated payment list"
            }
          }
        }
      },
      "/payments/stats": {
        "get": {
          "summary": "Get revenue statistics",
          "tags": [
            "Payments"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLotId",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "period",
              "schema": {
                "type": "string",
                "enum": [
                  "today",
                  "week",
                  "month",
                  "year"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Revenue stats"
            }
          }
        }
      },
      "/payments/cash": {
        "post": {
          "summary": "Process cash payment (staff)",
          "tags": [
            "Payments"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "sessionId",
                    "cashReceived"
                  ],
                  "properties": {
                    "sessionId": {
                      "type": "string"
                    },
                    "cashReceived": {
                      "type": "number",
                      "example": 50000
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Cash payment recorded"
            }
          }
        }
      },
      "/payments/bank-transfer/initiate": {
        "post": {
          "summary": "Initiate bank transfer payment with SEPay QR code",
          "description": "Creates a pending payment and returns QR code URL for customer to scan",
          "tags": [
            "Payments"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "sessionId"
                  ],
                  "properties": {
                    "sessionId": {
                      "type": "string",
                      "description": "Parking session ID (must be checked out)"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "QR code generated",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "object",
                    "properties": {
                      "qrUrl": {
                        "type": "string",
                        "description": "SEPay QR image URL"
                      },
                      "transferContent": {
                        "type": "string",
                        "example": "PAR1606A3B2C1"
                      },
                      "amount": {
                        "type": "number"
                      },
                      "bankInfo": {
                        "type": "object",
                        "properties": {
                          "bankName": {
                            "type": "string"
                          },
                          "accountNumber": {
                            "type": "string"
                          },
                          "accountName": {
                            "type": "string"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/payments/bank-transfer/booking/initiate": {
        "post": {
          "summary": "Initiate bank transfer payment for booking",
          "description": "Creates a pending payment and returns QR code URL for booking",
          "tags": [
            "Payments"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "bookingId"
                  ],
                  "properties": {
                    "bookingId": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "QR code generated"
            }
          }
        }
      },
      "/payments/bank-transfer/monthly-pass/initiate": {
        "post": {
          "summary": "Initiate bank transfer payment for monthly pass",
          "tags": [
            "Payments"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "monthlyPassId"
                  ],
                  "properties": {
                    "monthlyPassId": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "QR code generated"
            }
          }
        }
      },
      "/payments/bank-transfer/{id}/status": {
        "get": {
          "summary": "Check bank transfer payment status",
          "tags": [
            "Payments"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Payment status"
            }
          }
        }
      },
      "/reports/dashboard": {
        "get": {
          "summary": "Get dashboard overview statistics",
          "tags": [
            "Reports"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLotId",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Dashboard statistics"
            }
          }
        }
      },
      "/reports/revenue": {
        "get": {
          "summary": "Get revenue report",
          "tags": [
            "Reports"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "period",
              "schema": {
                "type": "string",
                "enum": [
                  "today",
                  "week",
                  "month",
                  "year"
                ]
              }
            },
            {
              "in": "query",
              "name": "groupBy",
              "schema": {
                "type": "string",
                "enum": [
                  "hour",
                  "day",
                  "month",
                  "year"
                ]
              }
            },
            {
              "in": "query",
              "name": "parkingLotId",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Revenue chart data and totals"
            }
          }
        }
      },
      "/reports/sessions": {
        "get": {
          "summary": "Get session report with peak hours analysis",
          "tags": [
            "Reports"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "period",
              "schema": {
                "type": "string",
                "enum": [
                  "today",
                  "week",
                  "month",
                  "year"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Session statistics and charts"
            }
          }
        }
      },
      "/reports/occupancy": {
        "get": {
          "summary": "Get occupancy rate by vehicle type",
          "tags": [
            "Reports"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "parkingLotId",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Occupancy data"
            }
          }
        }
      },
      "/reports/export/sessions": {
        "get": {
          "summary": "Export sessions as CSV",
          "tags": [
            "Reports"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "period",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "CSV file download",
              "content": {
                "text/csv": {
                  "schema": {
                    "type": "string"
                  }
                }
              }
            }
          }
        }
      },
      "/users/profile": {
        "get": {
          "summary": "Get my profile",
          "tags": [
            "Users"
          ],
          "responses": {
            "200": {
              "description": "Profile data"
            }
          }
        },
        "put": {
          "summary": "Update my profile",
          "tags": [
            "Users"
          ],
          "requestBody": {
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "fullName": {
                      "type": "string"
                    },
                    "phone": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Profile updated"
            }
          }
        }
      },
      "/users/avatar": {
        "put": {
          "summary": "Update profile avatar",
          "tags": [
            "Users"
          ],
          "requestBody": {
            "content": {
              "multipart/form-data": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "avatar": {
                      "type": "string",
                      "format": "binary"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Avatar updated"
            }
          }
        }
      },
      "/users/my-activity": {
        "get": {
          "summary": "Get my activity logs",
          "tags": [
            "Users"
          ],
          "responses": {
            "200": {
              "description": "Activity logs"
            }
          }
        }
      },
      "/users": {
        "get": {
          "summary": "Get all users (admin only)",
          "tags": [
            "Users"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer"
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer"
              }
            },
            {
              "in": "query",
              "name": "search",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "role",
              "schema": {
                "type": "string",
                "enum": [
                  "system_admin",
                  "parking_manager",
                  "parking_staff",
                  "parking_user"
                ]
              }
            },
            {
              "in": "query",
              "name": "status",
              "schema": {
                "type": "string",
                "enum": [
                  "active",
                  "inactive",
                  "blocked",
                  "pending"
                ]
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Paginated user list"
            }
          }
        },
        "post": {
          "summary": "Create user (admin only)",
          "tags": [
            "Users"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "fullName",
                    "email",
                    "password",
                    "role"
                  ],
                  "properties": {
                    "fullName": {
                      "type": "string"
                    },
                    "email": {
                      "type": "string"
                    },
                    "password": {
                      "type": "string"
                    },
                    "role": {
                      "type": "string"
                    },
                    "phone": {
                      "type": "string"
                    },
                    "assignedParkingLot": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "User created"
            }
          }
        }
      },
      "/users/{id}": {
        "get": {
          "summary": "Get user by ID (admin only)",
          "tags": [
            "Users"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "User data"
            },
            "404": {
              "description": "User not found"
            }
          }
        },
        "put": {
          "summary": "Update user (admin only)",
          "tags": [
            "Users"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "fullName": {
                      "type": "string",
                      "example": "Nguyen Van A"
                    },
                    "phone": {
                      "type": "string",
                      "example": "0912345678"
                    },
                    "role": {
                      "type": "string",
                      "enum": [
                        "system_admin",
                        "parking_manager",
                        "parking_staff",
                        "parking_user"
                      ],
                      "example": "parking_staff"
                    },
                    "status": {
                      "type": "string",
                      "enum": [
                        "active",
                        "inactive",
                        "blocked",
                        "pending"
                      ],
                      "example": "active"
                    },
                    "assignedParkingLot": {
                      "type": "string",
                      "description": "MongoDB ObjectId of the parking lot",
                      "example": "60d5ec49f1b2c72b9c8e4d3a"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "User updated"
            },
            "404": {
              "description": "User not found"
            }
          }
        },
        "delete": {
          "summary": "Delete user (admin only)",
          "tags": [
            "Users"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "User deleted"
            }
          }
        }
      },
      "/users/{id}/block": {
        "patch": {
          "summary": "Block a user",
          "tags": [
            "Users"
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "User blocked"
            }
          }
        }
      },
      "/vehicles": {
        "get": {
          "summary": "Get my vehicles",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer",
                "default": 1
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer",
                "default": 20
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of user vehicles"
            }
          }
        },
        "post": {
          "summary": "Add a new vehicle",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "vehicleType",
                    "licensePlate"
                  ],
                  "properties": {
                    "vehicleType": {
                      "type": "string",
                      "description": "MongoDB ObjectId of VehicleType",
                      "example": "60d5ec49f1b2c72b9c8e4d3a"
                    },
                    "licensePlate": {
                      "type": "string",
                      "example": "29A-12345"
                    },
                    "vehicleModel": {
                      "type": "string",
                      "example": "Honda Civic 2024"
                    },
                    "vehicleColor": {
                      "type": "string",
                      "example": "Trắng"
                    },
                    "vehicleBrand": {
                      "type": "string",
                      "example": "Honda"
                    },
                    "nickname": {
                      "type": "string",
                      "example": "Xe đi làm"
                    },
                    "isDefault": {
                      "type": "boolean",
                      "default": false
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Vehicle added"
            },
            "409": {
              "description": "Duplicate license plate"
            }
          }
        }
      },
      "/vehicles/default": {
        "get": {
          "summary": "Get my default vehicle",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Default vehicle data"
            }
          }
        }
      },
      "/vehicles/{id}": {
        "get": {
          "summary": "Get vehicle by ID",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Vehicle data"
            },
            "404": {
              "description": "Vehicle not found"
            }
          }
        },
        "put": {
          "summary": "Update vehicle",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "vehicleType": {
                      "type": "string"
                    },
                    "licensePlate": {
                      "type": "string"
                    },
                    "vehicleModel": {
                      "type": "string"
                    },
                    "vehicleColor": {
                      "type": "string"
                    },
                    "vehicleBrand": {
                      "type": "string"
                    },
                    "nickname": {
                      "type": "string"
                    },
                    "isDefault": {
                      "type": "boolean"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Vehicle updated"
            },
            "404": {
              "description": "Vehicle not found"
            }
          }
        },
        "delete": {
          "summary": "Delete vehicle",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Vehicle deleted"
            }
          }
        }
      },
      "/vehicles/{id}/default": {
        "patch": {
          "summary": "Set vehicle as default",
          "tags": [
            "Vehicles"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Default vehicle updated"
            }
          }
        }
      },
      "/zones": {
        "get": {
          "summary": "Get all zones",
          "tags": [
            "Zones"
          ],
          "parameters": [
            {
              "in": "query",
              "name": "floor",
              "schema": {
                "type": "string"
              }
            },
            {
              "in": "query",
              "name": "parkingLot",
              "schema": {
                "type": "string"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Zone list"
            }
          }
        },
        "post": {
          "summary": "Create zone",
          "tags": [
            "Zones"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "floor",
                    "parkingLot",
                    "name",
                    "code"
                  ],
                  "properties": {
                    "floor": {
                      "type": "string"
                    },
                    "parkingLot": {
                      "type": "string"
                    },
                    "name": {
                      "type": "string",
                      "example": "Khu A"
                    },
                    "code": {
                      "type": "string",
                      "example": "A"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Zone created"
            }
          }
        }
      },
      "/vehicle-types": {
        "get": {
          "summary": "Get all vehicle types",
          "tags": [
            "Vehicle Types"
          ],
          "responses": {
            "200": {
              "description": "Vehicle type list"
            }
          }
        },
        "post": {
          "summary": "Create vehicle type (admin)",
          "tags": [
            "Vehicle Types"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name",
                    "code",
                    "size",
                    "pricing"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "example": "Xe ô tô"
                    },
                    "code": {
                      "type": "string",
                      "example": "CAR"
                    },
                    "size": {
                      "type": "string",
                      "enum": [
                        "small",
                        "medium",
                        "large",
                        "extra_large"
                      ]
                    },
                    "pricing": {
                      "type": "object",
                      "properties": {
                        "dayBlockRate": {
                          "type": "number",
                          "example": 5000,
                          "description": "Price per 4-hour daytime block (6AM–6PM)"
                        },
                        "nightBlockRate": {
                          "type": "number",
                          "example": 7500,
                          "description": "Price per 4-hour nighttime block (6PM–6AM). Defaults to 1.5x dayBlockRate."
                        },
                        "dailyRate": {
                          "type": "number",
                          "example": 80000
                        },
                        "monthlyRate": {
                          "type": "number",
                          "example": 1500000
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Vehicle type created"
            }
          }
        }
      }
    }
  },
  "customOptions": {
    "persistAuthorization": true,
    "displayRequestDuration": true
  }
};
  url = options.swaggerUrl || url
  var urls = options.swaggerUrls
  var customOptions = options.customOptions
  var spec1 = options.swaggerDoc
  var swaggerOptions = {
    spec: spec1,
    url: url,
    urls: urls,
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  }
  for (var attrname in customOptions) {
    swaggerOptions[attrname] = customOptions[attrname];
  }
  var ui = SwaggerUIBundle(swaggerOptions)

  if (customOptions.oauth) {
    ui.initOAuth(customOptions.oauth)
  }

  if (customOptions.preauthorizeApiKey) {
    const key = customOptions.preauthorizeApiKey.authDefinitionKey;
    const value = customOptions.preauthorizeApiKey.apiKeyValue;
    if (!!key && !!value) {
      const pid = setInterval(() => {
        const authorized = ui.preauthorizeApiKey(key, value);
        if(!!authorized) clearInterval(pid);
      }, 500)

    }
  }

  if (customOptions.authAction) {
    ui.authActions.authorize(customOptions.authAction)
  }

  window.ui = ui
}
