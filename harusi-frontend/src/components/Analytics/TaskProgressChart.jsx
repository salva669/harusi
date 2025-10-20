import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line } from 'recharts';

export const TaskProgressChart = ({ comparison }) => {
  const taskData = [
    { name: 'Total', value: comparison.tasks.total },
    { name: 'Completed', value: comparison.tasks.completed },
    { name: 'Pending', value: comparison.tasks.pending },
    { name: 'Overdue', value: comparison.tasks.overdue }
  ];

  return (
    <div className="chart-container card">
      <h3>✓ Task Progress</h3>

      <div className="chart-stats">
        <div className="stat">
          <span className="label">Total Tasks:</span>
          <span className="value">{comparison.tasks.total}</span>
        </div>
        <div className="stat">
          <span className="label">Completed:</span>
          <span className="value completed">{comparison.tasks.completed}</span>
        </div>
        <div className="stat">
          <span className="label">Pending:</span>
          <span className="value pending">{comparison.tasks.pending}</span>
        </div>
        <div className="stat">
          <span className="label">Completion:</span>
          <span className="value">{comparison.tasks.completion_percentage.toFixed(1)}%</span>
        </div>
      </div>

      <div className="progress-bar-container">
        <div className="progress-bar-label">Overall Progress</div>
        <div className="progress-bar-bg">
          <div 
            className="progress-bar-fill"
            style={{ width: `${comparison.tasks.completion_percentage}%` }}
          >
            {comparison.tasks.completion_percentage.toFixed(0)}%
          </div>
        </div>
      </div>

      {comparison.tasks.overdue > 0 && (
        <div className="alert error">
          ⚠️ You have {comparison.tasks.overdue} overdue tasks. Please review and update!
        </div>
      )}

      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={taskData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Bar dataKey="value" fill="#667eea" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};