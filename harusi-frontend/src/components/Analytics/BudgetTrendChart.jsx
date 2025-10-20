import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export const BudgetTrendChart = ({ comparison }) => {
  const data = [
    {
      name: 'Estimated',
      amount: comparison.budget.estimated,
    },
    {
      name: 'Actual',
      amount: comparison.budget.actual,
    }
  ];

  const percentageSpent = (comparison.budget.actual / comparison.budget.estimated * 100).toFixed(1);
  const isOverBudget = comparison.budget.actual > comparison.budget.estimated;

  return (
    <div className="chart-container card">
      <h3>💰 Budget Overview</h3>
      
      <div className="chart-stats">
        <div className="stat">
          <span className="label">Estimated Budget:</span>
          <span className="value">TZS {comparison.budget.estimated.toLocaleString()}</span>
        </div>
        <div className="stat">
          <span className="label">Actual Spending:</span>
          <span className={`value ${isOverBudget ? 'over' : 'under'}`}>
            TZS {comparison.budget.actual.toLocaleString()}
          </span>
        </div>
        <div className="stat">
          <span className="label">Variance:</span>
          <span className={`value ${isOverBudget ? 'over' : 'under'}`}>
            {isOverBudget ? '+' : '-'} TZS {Math.abs(comparison.budget.variance).toLocaleString()}
          </span>
        </div>
        <div className="stat">
          <span className="label">Spent:</span>
          <span className="value">{percentageSpent}%</span>
        </div>
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip formatter={(value) => `TZS ${value.toLocaleString()}`} />
          <Bar dataKey="amount" fill="#667eea" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};