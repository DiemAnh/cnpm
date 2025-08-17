/* eslint-disable */
/*!
  _   _  ___  ____  ___ ________  _   _   _   _ ___   
 | | | |/ _ \|  _ \|_ _|__  / _ \| \ | | | | | |_ _| 
 | |_| | | | | |_) || |  / / | | |  \| | | | | || | 
 |  _  | |_| |  _ < | | / /| |_| | |\  | | |_| || |
 |_| |_|\___/|_| \_\___/____\___/|_| \_|  \___/|___|
                                                                                                                                                                                                                                                                                                                                       
=========================================================
* Horizon UI - v1.1.0
=========================================================

* Product Page: http://www.horizon-ui.com/
* Copyright 2023 Horizon UI (http://www.horizon-ui.com/)

* Designed and Coded by Simmmple

=========================================================

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*/

import React, { useState, useEffect } from 'react';
import { useToast } from '@chakra-ui/react';
import { NavLink } from 'react-router-dom';
import { useNavigate } from 'react-router-dom'; // Thêm import này
import { jwtDecode } from 'jwt-decode';
import { WarningIcon } from "@chakra-ui/icons"; // Nhúng icon từ Chakra UI
// Chakra imports
import {
  Box,
  Button,
  Checkbox,
  Flex,
  FormControl,
  FormLabel,
  Heading,
  Icon,
  Input,
  InputGroup,
  InputRightElement,
  Text,
  useColorModeValue,
  Select,
} from '@chakra-ui/react';
// Custom components
import { HSeparator } from 'components/separator/Separator';
import DefaultAuth from 'layouts/auth/Default';
// Assets
import illustration from 'assets/img/auth/auth.png';
import { FcGoogle } from 'react-icons/fc';
import { MdOutlineRemoveRedEye } from 'react-icons/md';
import { RiEyeCloseLine } from 'react-icons/ri';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL;

function SignUp() {
  // Chakra color mode
  const navigate = useNavigate(); // 🔹 Phải khai báo useNavigate() ở đây
  const toast = useToast(); // 🔹 Hook để hiển thị thông báo
  const textColor = useColorModeValue('navy.700', 'white');
  const textColorSecondary = 'gray.400';
  const textColorDetails = useColorModeValue('navy.700', 'secondaryGray.600');
  const textColorBrand = useColorModeValue('brand.500', 'white');
  const brandStars = useColorModeValue('brand.500', 'brand.400');
  const googleBg = useColorModeValue('secondaryGray.300', 'whiteAlpha.200');
  const googleText = useColorModeValue('navy.700', 'white');
  const googleHover = useColorModeValue(
    { bg: 'gray.200' },
    { bg: 'whiteAlpha.300' },
  );
  const googleActive = useColorModeValue(
    { bg: 'secondaryGray.300' },
    { bg: 'whiteAlpha.200' },
  );
  const [show, setShow] = React.useState(false);
  const handleClick = () => setShow(!show);

  const [fullName, setFullName] = useState('');
  const [age, setAge] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [apartmentNumbers, setApartmentNumbers] = useState(null);
  const [name, setName] = useState('');
  const [gender, setGender] = useState(''); // Thêm dòng này
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSignUp = async () => {
    // Reset lỗi ban đầu, đặt error là mảng rỗng
    setError([]);
  
    // Kiểm tra name và password có giá trị không
    if (!name.trim() || !password.trim()) {
      setError(['Username and password must not be empty.']);
      return;
    }
  
    const requestBody = {
      fullName,
      email,
      phone,
      age,
      gender,
      name,
      password,
    };

  
  
    try {
      const formattedData = {
        ...requestBody,
        apartmentNumbers: null // Nếu không hợp lệ, gán null
    };
    console.log(
      'Sending JSON to backend:',
      JSON.stringify(formattedData, null, 2)
    );
      const response = await fetch(`${API_BASE_URL}/api/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formattedData),
        credentials: 'include', // 🔥 QUAN TRỌNG: Đảm bảo gửi session cookie
      });
    
      const rawData = await response.json(); // Parse JSON từ backend
      console.log('Response:', rawData);

      // Nếu đăng ký thành công, chuyển hướng
      if (rawData.message === 'User saved to session successfully!') {

      const resendResponse = await fetch(`${API_BASE_URL}/api/auth/resend-otp`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include', // Đảm bảo session được gửi đi
      });
      toast({
        title: 'Registration Successful!',
        description: 'Sending OTP...',
        status: 'success',
        duration: 4000,
        isClosable: true,
    });

  
      const resendData = await resendResponse.json();
      console.log('Resend OTP Response:', resendData);
  
        localStorage.clear();
        setTimeout(() => {
          navigate('/auth/verify');
        }, 2000);
    
        return;
      }else{
        const errorMessages =
        rawData && typeof rawData === 'object' && rawData.errors
          ? Object.values(rawData.errors) // Extract all error messages
          : ['Verification failed'];
          setError(errorMessages); // Store errors as an array for UI mapping
          return; // Exit without throwing to avoid duplicate error logs
      }
  
    } catch (err) {
      console.error('Fetch Error:', err);
    
      let errorMessage = 'Error in server, please try later.';
    
      // Kiểm tra lỗi do kết nối không thành công
      if (err.message.includes('Failed to fetch') || err.message.includes('NetworkError')) {
        errorMessage = 'Error in server, please try later.';
      } else {
        errorMessage = err.message;
      }
    
      // Nếu errorMessage chứa dấu " | ", tách thành mảng
      if (errorMessage.includes(' | ')) {
        setError(errorMessage.split(' | '));
      } else {
        setError([errorMessage]);
      }
    }
  };
  
  return (
    <DefaultAuth illustrationBackground={illustration} image={illustration}>
      <Flex
        maxW={{ base: '100%', md: 'max-content' }}
        w="100%"
        mx={{ base: 'auto', lg: '0px' }}
        me="auto"
        h="100%"
        alignItems="start"
        justifyContent="center"
        mb={{ base: '30px', md: '60px' }}
        px={{ base: '25px', md: '0px' }}
        mt={{ base: '20px', md: '4vh' }}
        flexDirection="column"
      >
        <Box me="auto">
          <Heading color={textColor} fontSize="36px" mb="10px">
            Sign Up
          </Heading>
          <Text
            mb="36px"
            ms="4px"
            color={textColorSecondary}
            fontWeight="400"
            fontSize="md"
          >
            Enter your information to sign up!
          </Text>
        </Box>
        <Flex
          zIndex="2"
          direction="column"
          w={{ base: '100%', md: '670px' }}
          maxW="100%"
          background="transparent"
          borderRadius="15px"
          mx={{ base: 'auto', lg: 'unset' }}
          me="auto"
          mb={{ base: '20px', md: 'auto' }}
        >
          <Flex direction="row" w="100%" gap="20px">
            <Box flex="1">
              <FormControl>
                <FormLabel
                  display="flex"
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  mb="8px"
                >
                  Username<Text color={brandStars}>*</Text>
                </FormLabel>
                <Input
                  isRequired={true}
                  variant="auth"
                  fontSize="sm"
                  ms={{ base: '0px', md: '0px' }}
                  type="email"
                  placeholder="username"
                  mb="24px"
                  fontWeight="500"
                  size="lg"
                  value={name} // Thêm dòng này để liên kết state với input
                  onChange={(e) => setName(e.target.value)}
                />
                <FormLabel
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  display="flex"
                >
                  Password<Text color={brandStars}>*</Text>
                </FormLabel>
                <InputGroup size="md">
                  <Input
                    isRequired={true}
                    fontSize="sm"
                    placeholder="Min. 8 characters"
                    mb="24px"
                    size="lg"
                    type={show ? 'text' : 'password'}
                    variant="auth"
                    value={password} // Thêm dòng này để liên kết state với input
                    onChange={(e) => setPassword(e.target.value)}
                  />
                  <InputRightElement
                    display="flex"
                    alignItems="center"
                    mt="4px"
                  >
                    <Icon
                      color={textColorSecondary}
                      _hover={{ cursor: 'pointer' }}
                      as={show ? RiEyeCloseLine : MdOutlineRemoveRedEye}
                      onClick={handleClick}
                    />
                  </InputRightElement>
                </InputGroup>
                <FormLabel
                  display="flex"
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  mb="8px"
                >
                  Email<Text color={brandStars}>*</Text>
                </FormLabel>
                <Input
                  isRequired={true}
                  variant="auth"
                  fontSize="sm"
                  ms={{ base: '0px', md: '0px' }}
                  type="email"
                  placeholder="nguyenvana@gmail.com"
                  mb="24px"
                  fontWeight="500"
                  size="lg"
                  value={email} // Thêm dòng này để liên kết state với input
                  onChange={(e) => setEmail(e.target.value)}
                />
                <FormLabel
                  display="flex"
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  mb="8px"
                >
                  Phone<Text color={brandStars}>*</Text>
                </FormLabel>
                <Input
                  isRequired={true}
                  variant="auth"
                  fontSize="sm"
                  ms={{ base: '0px', md: '0px' }}
                  type="phone"
                  mb="24px"
                  fontWeight="500"
                  size="lg"
                  value={phone} // Thêm dòng này để liên kết state với input
                  onChange={(e) => setPhone(e.target.value)}
                />
                <Flex justifyContent="space-between" align="center" mb="24px">
                  <FormControl display="flex" alignItems="center">
                    <Checkbox
                      id="remember-login"
                      colorScheme="brandScheme"
                      me="10px"
                    />
                    <Text fontSize="sm" color={textColor}>
                      I agree to the{' '}
                      <Text
                        as="span"
                        fontWeight="bold"
                        color={textColorBrand}
                        cursor="pointer"
                        _hover={{ textDecoration: 'underline' }}
                        onClick={() =>
                          console.log('Clicked Terms and Conditions')
                        }
                      >
                        Terms and Conditions
                      </Text>
                    </Text>
                  </FormControl>
                </Flex>
                <Button
                  fontSize="sm"
                  variant="brand"
                  fontWeight="500"
                  w="100%"
                  h="50"
                  mb="24px"
                  onClick={handleSignUp}
                >
                  Sign Up
                </Button>
              </FormControl>
            </Box>
            {/* Cột 2 */}
            <Box flex="1">
              <FormControl>
              <FormLabel
                  display="flex"
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  mb="8px"
                >
                  Full name<Text color={brandStars}>*</Text>
                </FormLabel>
                <Input
                  isRequired={true}
                  variant="auth"
                  fontSize="sm"
                  ms={{ base: '0px', md: '0px' }}
                  type="fullName"
                  placeholder="Nguyen Van A"
                  mb="24px"
                  fontWeight="500"
                  size="lg"
                  value={fullName} // Thêm dòng này để liên kết state với input
                  onChange={(e) => setFullName(e.target.value)}
                />

                <FormLabel
                  display="flex"
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  mb="8px"
                >
                  Age<Text color={brandStars}>*</Text>
                </FormLabel>
                <Input
                  isRequired={true}
                  variant="auth"
                  fontSize="sm"
                  ms={{ base: '0px', md: '0px' }}
                  type="phone"
                  mb="24px"
                  fontWeight="500"
                  size="lg"
                  value={age} // Thêm dòng này để liên kết state với input
                  onChange={(e) => setAge(e.target.value)}
                />

                <FormLabel
                  display="flex"
                  ms="4px"
                  fontSize="sm"
                  fontWeight="500"
                  color={textColor}
                  mb="8px"
                >
                  Gender<Text color={brandStars}>*</Text>
                </FormLabel>
                <Select
                  isRequired={true}
                  variant="auth"
                  fontSize="sm"
                  ms={{ base: '0px', md: '0px' }}
                  placeholder="Select Gender"
                  mb="24px"
                  fontWeight="500"
                  size="lg"
                  value={gender} // Thêm dòng này để liên kết state với input
                  onChange={(e) => setGender(e.target.value)}
                >
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                </Select>
{error && (
  <Box ms="4px" mb="8px">
    {error.map((errMsg, index) => (
      <Text key={index} fontSize="sm" fontWeight="bold" color="red.500" display="flex" alignItems="center">
        <WarningIcon boxSize={4} color="red.500" mr={2} /> {/* Icon cảnh báo */}
        {errMsg}
      </Text>
    ))}
  </Box>
)}
              </FormControl>
            </Box>
          </Flex>
        </Flex>
      </Flex>
    </DefaultAuth>
  );
}

export default SignUp;
