import React from 'react';
import { Icon } from '@chakra-ui/react';
import {
  MdBarChart,
  MdPerson,
  MdLock,
  MdOutlineShoppingCart,
  MdFeedback,
  MdHome,
  MdPayment,
  MdLocalParking,
  MdAttachMoney,
  MdReceiptLong,
  MdWaterDrop,
  MdElectricalServices,
  MdLibraryBooks,
  MdSell,
  MdPeople,
  MdNotifications,
  MdExplore,
  MdLocationCity,
} from 'react-icons/md';

// Admin, user Imports
import Profile from 'views/admin/profile';
import UserProfile from 'views/user/profile';
import Bill from "views/admin/bill";
import UserPay from 'views/user/payment';
// Auth Imports
import SignInCentered from 'views/auth/signIn';
import SignUpCentered from 'views/auth/signUp';
import VerifySignUpCentered from 'views/auth/verify';
import ForgotSignUpCentered from 'views/auth/forgotPassword';
import VerifyForgotSignUpCentered from 'views/auth/verifyForgot';
import AdminApartment from 'views/admin/apartment';
import UserTable from 'views/admin/user';
import UserHomePage from 'views/user/homepage';
import AdminHomePage from 'views/admin/homepage';
// Admin routes
export const adminRoutes = [
  {
    name: 'Admin Main Dashboard',
    layout: '/admin',
    path: '/data-tables',
    icon: (
      <Icon
        as={MdLocationCity}
        width="20px"
        height="20px"
        color="inherit"
      />
    ),
    component: <AdminHomePage />,
    secondary: true,
  },
  {
    name: 'Profile',
    layout: '/admin',
    path: '/profile',
    icon: <Icon as={MdPerson} width="20px" height="20px" color="inherit" />,
    component: <Profile />,
  },
  {
    name: 'Apartment Management',
    layout: '/admin',
    path: '/apartment',
    icon: <Icon as={MdHome} width="20px" height="20px" color="inherit" />,
    component: <AdminApartment />,
  },
  {
    name: 'Resident Management',
    layout: '/admin',
    path: '/resident',
    icon: <Icon as={MdPeople} width="20px" height="20px" color="inherit" />,
    component: <UserTable />,
  },
  {
    name: 'Bill Management',
    layout: '/admin',
    path: '/bill',
    icon: <Icon as={MdReceiptLong} width="20px" height="20px" color="inherit" />,
    component: <Bill />,
  },
];

// User routes
export const userRoutes = [
    {
    name: 'User Profile',
    layout: '/user',
    path: '/profile-user',
    icon: <Icon as={MdPerson} width="20px" height="20px" color="inherit" />,
    component: <UserProfile />,
  },
  {
    name: 'User Homepage',
    layout: '/user',
    path: '/profile',
    icon: <Icon as={MdPerson} width="20px" height="20px" color="inherit" />,
    component: <UserHomePage />,
  },
  {
    name: 'Bill Payment Service',
    layout: '/user',
    path: '/payment',
    icon: <Icon as={MdPayment} width="20px" height="20px" color="inherit" />,
    component: <UserPay />,
  },
];

// Auth routes
export const authRoutes = [
  {
    name: 'Sign In',
    layout: '/auth',
    path: '/sign-in',
    icon: <Icon as={MdLock} width="20px" height="20px" color="inherit" />,
    component: <SignInCentered />,
  },
  {
    layout: '/auth',
    path: '/sign-up',
    component: <SignUpCentered />,
  },
  {
    layout: '/auth',
    path: '/verify',
    component: <VerifySignUpCentered />,
  },
  {
    layout: '/auth',
    path: '/forgot-password',
    component: <ForgotSignUpCentered />,
  },
  {
    layout: '/auth',
    path: '/verify-forgot-password',
    component: <VerifyForgotSignUpCentered />,
  },
];

// Combine all routes
const routes = [...adminRoutes, ...userRoutes, ...authRoutes];

export default routes;
