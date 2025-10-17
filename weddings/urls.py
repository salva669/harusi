from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import WeddingViewSet, GuestViewSet, TaskViewSet, BudgetViewSet

router = DefaultRouter()
router.register(r'weddings', WeddingViewSet, basename='wedding')

wedding_router = DefaultRouter()
wedding_router.register(r'guests', GuestViewSet, basename='guest')
wedding_router.register(r'tasks', TaskViewSet, basename='task')
wedding_router.register(r'budget', BudgetViewSet, basename='budget')

urlpatterns = [
    path('', include(router.urls)),
    path('weddings/<int:wedding_id>/', include(wedding_router.urls)),
]