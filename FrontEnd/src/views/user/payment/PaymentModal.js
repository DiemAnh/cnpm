import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalFooter,
  ModalCloseButton,
  Button,
  Flex,
  Text,
  useColorModeValue,
} from '@chakra-ui/react';

const PaymentModal = ({ isOpen, onClose }) => {
  const textColor = useColorModeValue('secondaryGray.900', 'white');

  return (
    <Modal isOpen={isOpen} onClose={onClose} size="lg">
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>
          <Text fontSize="lg" fontWeight="700" color={textColor}>
            Payment
          </Text>
        </ModalHeader>
        <ModalCloseButton />
        <ModalBody>
          <Flex justify="center" align="center" h="150px">
            <Text fontSize="md" fontWeight="500" color={textColor}>
              Các bạn hãy hoàn thiện tiếp chức năng thanh toán
            </Text>
          </Flex>
        </ModalBody>
        <ModalFooter>
          <Button
            variant="whiteBrand"
            color="dark"
            fontSize="sm"
            fontWeight="500"
            borderRadius="10px"
            px="15px"
            py="5px"
            onClick={onClose}
          >
            Close
          </Button>
        </ModalFooter>
      </ModalContent>
    </Modal>
  );
};

export default PaymentModal;
