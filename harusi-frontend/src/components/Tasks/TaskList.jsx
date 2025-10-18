import { useState, useEffect } from 'react';
import { taskAPI } from '../../services/api';
import { TaskForm } from './TaskForm';
import { Loading } from '../Common/Loading';
import './Tasks.css';

export const TaskList = ({ weddingId }) => {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingTask, setEditingTask] = useState(null);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    loadTasks();
  }, [weddingId]);

  const loadTasks = async () => {
    try {
      const response = await taskAPI.getAll(weddingId);
      setTasks(response.data);
    } catch (err) {
      console.error('Failed to load tasks');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (taskId) => {
    if (window.confirm('Delete this task?')) {
      try {
        await taskAPI.delete(weddingId, taskId);
        setTasks(tasks.filter(t => t.id !== taskId));
      } catch (err) {
        console.error('Failed to delete task');
      }
    }
  };

  const handleStatusChange = async (taskId, newStatus) => {
    try {
      const task = tasks.find(t => t.id === taskId);
      await taskAPI.update(weddingId, taskId, { ...task, status: newStatus });
      loadTasks();
    } catch (err) {
      console.error('Failed to update task');
    }
  };

  const handleSave = () => {
    loadTasks();
    setShowForm(false);
    setEditingTask(null);
  };

  if (loading) return <Loading />;

  const filteredTasks = tasks.filter(t => 
    filter === 'all' ? true : t.status === filter
  );

  const taskStats = {
    todo: tasks.filter(t => t.status === 'todo').length,
    in_progress: tasks.filter(t => t.status === 'in_progress').length,
    done: tasks.filter(t => t.status === 'done').length,
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h2>Wedding Tasks</h2>
        <button className="primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? '✕ Cancel' : '+ Add Task'}
        </button>
      </div>

      {showForm && (
        <TaskForm 
          weddingId={weddingId}
          task={editingTask}
          onSave={handleSave}
          onCancel={() => { setShowForm(false); setEditingTask(null); }}
        />
      )}

      <div className="task-stats">
        <button 
          className={`stat-filter ${filter === 'all' ? 'active' : ''}`}
          onClick={() => setFilter('all')}
        >
          All ({tasks.length})
        </button>
        <button 
          className={`stat-filter ${filter === 'todo' ? 'active' : ''}`}
          onClick={() => setFilter('todo')}
        >
          To Do ({taskStats.todo})
        </button>
        <button 
          className={`stat-filter ${filter === 'in_progress' ? 'active' : ''}`}
          onClick={() => setFilter('in_progress')}
        >
          In Progress ({taskStats.in_progress})
        </button>
        <button 
          className={`stat-filter ${filter === 'done' ? 'active' : ''}`}
          onClick={() => setFilter('done')}
        >
          Done ({taskStats.done})
        </button>
      </div>

      {filteredTasks.length === 0 ? (
        <div className="empty-state">
          <p>No tasks found</p>
        </div>
      ) : (
        <div className="task-list">
          {filteredTasks.map(task => (
            <div key={task.id} className={`task-card card priority-${task.priority}`}>
              <div className="task-header">
                <div className="task-title">
                  <input 
                    type="checkbox"
                    checked={task.status === 'done'}
                    onChange={(e) => handleStatusChange(task.id, e.target.checked ? 'done' : 'todo')}
                    style={{ marginRight: '10px' }}
                  />
                  <h3>{task.title}</h3>
                </div>
                <span className={`priority-badge ${task.priority}`}>
                  {task.priority}
                </span>
              </div>
              {task.description && <p className="task-description">{task.description}</p>}
              <div className="task-meta">
                {task.due_date && <span>📅 {new Date(task.due_date).toLocaleDateString()}</span>}
                {task.assigned_to && <span>👤 {task.assigned_to}</span>}
                {task.cost && <span>💰 TZS {task.cost.toLocaleString()}</span>}
              </div>
              <select 
                value={task.status} 
                onChange={(e) => handleStatusChange(task.id, e.target.value)}
                className="status-select"
              >
                <option value="todo">To Do</option>
                <option value="in_progress">In Progress</option>
                <option value="done">Done</option>
              </select>
              <div className="task-actions">
                <button 
                  className="secondary" 
                  onClick={() => { setEditingTask(task); setShowForm(true); }}
                >
                  Edit
                </button>
                <button 
                  className="danger" 
                  onClick={() => handleDelete(task.id)}
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
