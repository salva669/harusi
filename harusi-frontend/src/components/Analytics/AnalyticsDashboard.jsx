import { useState, useEffect } from 'react';
import  api  from '../../services/api';
import { Loading } from '../Common/Loading';
import { HealthScoreCards } from './HealthScoreCards';
import { BudgetTrendChart } from './BudgetTrendChart';
import { GuestMetricsChart } from './GuestMetricsChart';
import { TaskProgressChart } from './TaskProgressChart';
import { CategoryBreakdownChart } from './CategoryBreakdownChart';
import './Analytics.css';

export const AnalyticsDashboard = ({ weddingId }) => {
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    loadAnalytics();
  }, [weddingId]);

  const loadAnalytics = async () => {
    try {
      const response = await api.get(`/weddings/${weddingId}/analytics/detailed/`);
      setAnalytics(response.data);
    } catch (err) {
      console.error('Failed to load analytics');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <Loading />;
  if (!analytics) return <div>No analytics data available</div>;

  return (
    <div className="analytics-dashboard">
      <h2>📊 Wedding Analytics Dashboard</h2>

      <div className="analytics-tabs">
        <button 
          className={`tab-btn ${activeTab === 'overview' ? 'active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button 
          className={`tab-btn ${activeTab === 'budget' ? 'active' : ''}`}
          onClick={() => setActiveTab('budget')}
        >
          Budget Analysis
        </button>
        <button 
          className={`tab-btn ${activeTab === 'guests' ? 'active' : ''}`}
          onClick={() => setActiveTab('guests')}
        >
          Guest Analytics
        </button>
        <button 
          className={`tab-btn ${activeTab === 'tasks' ? 'active' : ''}`}
          onClick={() => setActiveTab('tasks')}
        >
          Task Progress
        </button>
      </div>

      {activeTab === 'overview' && (
        <div className="tab-content">
          <HealthScoreCards healthReport={analytics.health_report} />
          <div className="analytics-grid">
            <BudgetTrendChart comparison={analytics.comparison} />
            <GuestMetricsChart comparison={analytics.comparison} />
            <TaskProgressChart comparison={analytics.comparison} />
          </div>
        </div>
      )}

      {activeTab === 'budget' && (
        <div className="tab-content">
          <CategoryBreakdownChart weddingId={weddingId} />
          <BudgetTrendChart comparison={analytics.comparison} />
        </div>
      )}

      {activeTab === 'guests' && (
        <div className="tab-content">
          <GuestMetricsChart comparison={analytics.comparison} />
        </div>
      )}

      {activeTab === 'tasks' && (
        <div className="tab-content">
          <TaskProgressChart comparison={analytics.comparison} />
        </div>
      )}
    </div>
  );
};