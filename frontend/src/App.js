import './App.css';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './Login/Login.js';
import Dashboard from './Dashboard/Dashboard.js';
import Quiz from './Quiz/Quiz.js';
import ResetPassword from './Login/ResetPassword.js'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/*" element={<Dashboard />} />
        <Route path="/login" element={<Login />} />
        <Route path="/quiz" element={<Quiz />} />
        <Route path="/reset-password" element={<ResetPassword />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;