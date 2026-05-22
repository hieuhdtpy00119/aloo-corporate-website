import { registrationService } from './cmsService'

export const createFranchiseRegistration = (payload) =>
  registrationService.create(payload)
