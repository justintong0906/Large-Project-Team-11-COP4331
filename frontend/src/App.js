import './App.css';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './Login/Login.js';
import Dashboard from './Dashboard/Dashboard.js';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="" element={<Dashboard />} />
        <Route path="/login" element={<Login />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;