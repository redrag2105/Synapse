export type AdminUser = {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
  admin?: boolean;
  [claim: string]: unknown;
};
