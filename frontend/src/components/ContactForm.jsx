import { useState } from 'react';
import axios from 'axios';
import { motion } from 'framer-motion';

const ContactForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });
  const [status, setStatus] = useState('idle'); // idle, loading, success, error

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus('loading');

    try {
      const apiUrl = import.meta.env.VITE_API_URL;
      
      // POST request to your API Gateway -> Lambda -> DynamoDB
      await axios.post(`${apiUrl}/contact`, formData);
      
      setStatus('success');
      setFormData({ name: '', email: '', message: '' });
    } catch (error) {
      console.error("API Error:", error);
      setStatus('error');
    }
  };

  return (
    <section className="p-8 max-w-lg mx-auto bg-white rounded-xl shadow-lg mt-10">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">Contact Me</h2>
      
      {status === 'success' && (
        <motion.div 
          initial={{ opacity: 0 }} 
          animate={{ opacity: 1 }}
          className="p-4 mb-4 text-green-700 bg-green-100 rounded"
        >
          Message sent successfully! I'll get back to you soon.
        </motion.div>
      )}

      {status === 'error' && (
        <div className="p-4 mb-4 text-red-700 bg-red-100 rounded">
          Failed to send message. Please try again.
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Name</label>
          <input
            type="text"
            name="name"
            required
            value={formData.name}
            onChange={handleChange}
            className="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Email</label>
          <input
            type="email"
            name="email"
            required
            value={formData.email}
            onChange={handleChange}
            className="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Message</label>
          <textarea
            name="message"
            rows="4"
            required
            value={formData.message}
            onChange={handleChange}
            className="mt-1 block w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
          ></textarea>
        </div>

        <button
          type="submit"
          disabled={status === 'loading'}
          className="w-full bg-blue-600 text-white p-2 rounded-md hover:bg-blue-700 transition disabled:bg-gray-400"
        >
          {status === 'loading' ? 'Sending...' : 'Send Message'}
        </button>
      </form>
    </section>
  );
};

export default ContactForm;