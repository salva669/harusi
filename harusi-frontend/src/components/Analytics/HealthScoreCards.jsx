import './Analytics.css';

export const HealthScoreCards = ({ healthReport }) => {
  const getScoreColor = (score) => {
    if (score >= 85) return '#10b981';
    if (score >= 70) return '#f59e0b';
    return '#ef4444';
  };

  const getScoreLabel = (score) => {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    return 'Needs Work';
  };

  const ScoreCard = ({ title, score, icon }) => (
    <div className="health-card">
      <div className="health-card-icon">{icon}</div>
      <h3>{title}</h3>
      <div className="health-score-container">
        <div 
          className="health-score-circle"
          style={{ borderColor: getScoreColor(score) }}
        >
          <span className="score-number">{Math.round(score)}</span>
          <span className="score-percent">%</span>
        </div>
        <p className="score-label" style={{ color: getScoreColor(score) }}>
          {getScoreLabel(score)}
        </p>
      </div>
    </div>
  );

  return (
    <div className="health-cards-grid">
      <ScoreCard 
        title="Budget Health" 
        score={healthReport.budget_health} 
        icon="💰"
      />
      <ScoreCard 
        title="Task Health" 
        score={healthReport.task_health} 
        icon="✓"
      />
      <ScoreCard 
        title="Guest Health" 
        score={healthReport.guest_health} 
        icon="👥"
      />
      <ScoreCard 
        title="Planning Health" 
        score={healthReport.planning_health} 
        icon="📅"
      />
      <div className="overall-health-card">
        <h3>Overall Health</h3>
        <div 
          className="overall-score-circle"
          style={{ borderColor: getScoreColor(healthReport.overall_health) }}
        >
          <span className="overall-score">{Math.round(healthReport.overall_health)}</span>
        </div>
        <p style={{ color: getScoreColor(healthReport.overall_health), textAlign: 'center' }}>
          {healthReport.overall_health >= 85 ? 'On Track! 🎉' : 
           healthReport.overall_health >= 70 ? 'Good Progress' : 
           'Needs Attention'}
        </p>
      </div>
    </div>
  );
};