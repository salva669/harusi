import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { Navbar } from './components/Navigation/Navbar';
import { PrivateRoute } from './components/Common/PrivateRoute';
import { Login } from './components/Auth/Login';
import { Register } from './components/Auth/Register';
import { WeddingList } from './components/Wedding/WeddingList';
import { WeddingForm } from './components/Wedding/WeddingForm';
import { WeddingDetail } from './components/Wedding/WeddingDetail';
import './App.css';

function App() {
  return (
    <Router>
      <AuthProvider>
        <Navbar />
        <main style={{ minHeight: '100vh', paddingBottom: '40px' }}>
          <Routes>
            {/* Public Routes */}
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            
            {/* Protected Routes */}
            <Route 
              path="/" 
              element={
                <PrivateRoute>
                  <WeddingList />
                </PrivateRoute>
              } 
            />
            
            <Route 
              path="/weddings/new" 
              element={
                <PrivateRoute>
                  <WeddingForm />
                </PrivateRoute>
              } 
            />
            
            <Route 
              path="/weddings/:id" 
              element={
                <PrivateRoute>
                  <WeddingDetail />
                </PrivateRoute>
              } 
            />
            
            <Route 
              path="/weddings/:id/edit" 
              element={
                <PrivateRoute>
                  <WeddingForm />
                </PrivateRoute>
              } 
            />
            
            {/* Catch-all - redirect to home */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </AuthProvider>
    </Router>
  );
}

export default App;