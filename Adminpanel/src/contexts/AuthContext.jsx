import { createContext, useContext, useState, useEffect } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    // Check if user is already logged in
    const token = localStorage.getItem('admin_token');
    if (token) {
      checkAuth();
    } else {
      setLoading(false);
    }
  }, []);

  const checkAuth = async () => {
    // Development mode: Check for mock token
    const DEV_MODE = import.meta.env.VITE_DEV_MODE === 'true' || !import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_BASE_URL.includes('example.com');
    
    if (DEV_MODE) {
      const token = localStorage.getItem('admin_token');
      if (token && token.startsWith('dev_mock_token_')) {
        setUser({
          id: 'admin-1',
          email: 'admin@saviored.com',
          name: 'Admin User',
        });
        setIsAuthenticated(true);
        setLoading(false);
        return;
      }
    }

    // Production mode: Real API check
    try {
      const response = await authAPI.getProfile();
      setUser(response.data);
      setIsAuthenticated(true);
    } catch (error) {
      localStorage.removeItem('admin_token');
      setIsAuthenticated(false);
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    // Development mode: Mock authentication for testing
    // Remove this in production or when backend is ready
    const DEV_MODE = import.meta.env.VITE_DEV_MODE === 'true' || !import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_BASE_URL.includes('example.com');
    
    if (DEV_MODE) {
      // Mock credentials for development
      if (email === 'admin@saviored.com' && password === 'admin123') {
        const mockToken = 'dev_mock_token_' + Date.now();
        const mockUser = {
          id: 'admin-1',
          email: 'admin@saviored.com',
          name: 'Admin User',
        };
        localStorage.setItem('admin_token', mockToken);
        setUser(mockUser);
        setIsAuthenticated(true);
        return { success: true };
      } else {
        return {
          success: false,
          error: 'Invalid credentials. Use admin@saviored.com / admin123 for development mode.',
        };
      }
    }

    // Production mode: Real API authentication
    try {
      const response = await authAPI.login(email, password);
      const { token, user: userData } = response.data;
      localStorage.setItem('admin_token', token);
      setUser(userData);
      setIsAuthenticated(true);
      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Login failed. Please check your credentials.',
      };
    }
  };

  const logout = async () => {
    try {
      await authAPI.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      localStorage.removeItem('admin_token');
      setUser(null);
      setIsAuthenticated(false);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        isAuthenticated,
        login,
        logout,
        checkAuth,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

