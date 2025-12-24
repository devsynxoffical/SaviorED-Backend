import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import MainLayout from './components/Layout/MainLayout';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import FocusSessions from './pages/FocusSessions';
import CastleGrounds from './pages/CastleGrounds';
import Leaderboard from './pages/Leaderboard';
import TreasureChests from './pages/TreasureChests';
import './App.css';

function App() {
  return (
    <Router>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <Dashboard />
                </MainLayout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/users"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <Users />
                </MainLayout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/focus-sessions"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <FocusSessions />
                </MainLayout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/castle-grounds"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <CastleGrounds />
                </MainLayout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/leaderboard"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <Leaderboard />
                </MainLayout>
              </ProtectedRoute>
            }
          />
          <Route
            path="/treasure-chests"
            element={
              <ProtectedRoute>
                <MainLayout>
                  <TreasureChests />
                </MainLayout>
              </ProtectedRoute>
            }
          />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </Router>
  );
}

export default App;
