"""
URL configuration for harusi_backend project.
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework import serializers
from rest_framework.permissions import AllowAny
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']

@api_view(['GET'])
def get_user(request):
    if request.user.is_authenticated:
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    else:
        return Response({'error': 'Not authenticated'}, status=401)

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    username = request.data.get('name')  # Flutter sends 'name' as username
    email = request.data.get('email')
    password = request.data.get('password')
    phone = request.data.get('phone')
    user_type = request.data.get('user_type')
    
    print("=" * 50)
    print(f"Registration attempt")
    print(f"Username: {username}")
    print(f"Email: {email}")
    print(f"Phone: {phone}")
    print(f"User Type: {user_type}")
    print("=" * 50)
    
    # Validation
    if not username or not email or not password:
        return Response({
            'error': 'Username, email, and password are required'
        }, status=400)
    
    if User.objects.filter(username=username).exists():
        return Response({
            'error': 'Username already exists'
        }, status=400)
    
    if User.objects.filter(email=email).exists():
        return Response({
            'error': 'Email already exists'
        }, status=400)
    
    try:
        # Create user
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password
        )
        
        # Create token for auto-login
        token, created = Token.objects.get_or_create(user=user)
        
        print(f"User created successfully: {user.username}")
        
        return Response({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'token': token.key,
            'message': 'Registration successful'
        }, status=201)
        
    except Exception as e:
        print(f"Registration error: {e}")
        return Response({
            'error': f'Registration failed: {str(e)}'
        }, status=400)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')
    
    print("=" * 50)
    print(f"Login attempt received")
    print(f"Username: '{username}'")
    print(f"Password provided: {bool(password)}")
    print(f"Request data: {request.data}")
    print("=" * 50)
    
    if not username or not password:
        print("ERROR: Missing username or password")
        return Response({'error': 'Username and password are required'}, status=400)
    
    # Check if user exists
    user_exists = User.objects.filter(username=username).exists()
    print(f"User '{username}' exists: {user_exists}")
    
    if user_exists:
        db_user = User.objects.get(username=username)
        print(f"User is active: {db_user.is_active}")
    
    user = authenticate(username=username, password=password)
    print(f"Authentication result: {user}")
    
    if user:
        token, created = Token.objects.get_or_create(user=user)
        print(f"Login successful! Token: {token.key[:10]}...")
        return Response({
            'token': token.key,
            'user': {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
            }
        })
    else:
        print("ERROR: Invalid credentials")
        return Response({'error': 'Invalid username or password'}, status=401)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('weddings.urls')),
    path('api-auth/', include('rest_framework.urls')),
    path('api/auth-token/', login, name='auth_token'),
    path('api/user/', get_user, name='get_user'),
    path('api/register/', register, name='register'),
]