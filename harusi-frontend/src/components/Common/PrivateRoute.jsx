import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { Loading } from './Loading';

export const PrivateRoute = ({ children }) => {
  const { token, loading } = useAuth();

  if (loading) return <Loading />;

  return token ? children : <Navigate to="/login" />;
};