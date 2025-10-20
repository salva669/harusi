import { useState, useEffect } from 'react';
import  api  from '../../services/api';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Loading } from '../Common/Loading';

export const CategoryBreakdownChart = ({ weddingId }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadCategoryData();
  }, [weddingId]);

  const loadCategoryData = async () => {
    try {
      const response = await api.get(`/weddings/${weddingId}/analytics/budget-breakdown/`);
      setData(response.data.breakdown);
    } catch (err) {
      console.error('Failed to load category data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <Loading />;
  if (!data) return <div>No data available</div>;

  return (
    <div className="chart-container card">
      <h3>📊 Budget by Category</h3>

      <div className="category-table">
        <table>
          <thead>
            <tr>
              <th>Category</th>
              <th>Estimated</th>
              <th>Actual</th>
              <th>Variance</th>
              <th>% of Budget</th>
            </tr>
          </thead>
          <tbody>
            {data.map((item, index) => (
              <tr key={index}>
                <td className="category-name">
                  {item.category.replace(/_/g, ' ').toUpperCase()}
                </td>
                <td>TZS {item.estimated.toLocaleString()}</td>
                <td className={item.actual > item.estimated ? 'over' : 'under'}>
                  TZS {item.actual.toLocaleString()}
                </td>
                <td className={item.variance >= 0 ? 'positive' : 'negative'}>
                  TZS {item.variance.toLocaleString()}
                </td>
                <td>{item.percentage_of_budget.toFixed(1)}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <ResponsiveContainer width="100%" height={400}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis 
            dataKey="category" 
            angle={-45}
            textAnchor="end"
            height={100}
          />
          <YAxis />
          <Tooltip formatter={(value) => `TZS ${value.toLocaleString()}`} />
          <Legend />
          <Bar dataKey="estimated" fill="#3b82f6" name="Estimated" />
          <Bar dataKey="actual" fill="#ef4444" name="Actual" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};