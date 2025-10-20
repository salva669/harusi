from rest_framework import serializers
from .analytics_models import (
    WeddingAnalytics, WeeklyAnalyticsSnapshot, GuestEngagementMetrics
)

class WeddingAnalyticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeddingAnalytics
        fields = '__all__'


class WeeklyAnalyticsSnapshotSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeeklyAnalyticsSnapshot
        fields = '__all__'


class GuestEngagementMetricsSerializer(serializers.ModelSerializer):
    class Meta:
        model = GuestEngagementMetrics
        fields = '__all__'