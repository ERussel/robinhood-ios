/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import Foundation

extension CoreDataRepository: DataProviderRepositoryProtocol {
    public func fetchOperation(by modelId: String) -> BaseOperation<Model?> {
        return ClosureOperation {
            var model: Model?
            var error: Error?

            let semaphore = DispatchSemaphore(value: 0)

            self.fetch(by: modelId,
                       runCompletionIn: nil) { (optionalModel, optionalError) in
                        model = optionalModel
                        error = optionalError

                        semaphore.signal()
            }

            semaphore.wait()

            if let existingModel = model {
                return existingModel
            }

            if let existingError = error {
                throw existingError
            }

            return nil
        }
    }

    public func fetchAllOperation() -> BaseOperation<[Model]> {
        return ClosureOperation {
            var models: [Model]?
            var error: Error?

            let semaphore = DispatchSemaphore(value: 0)

            self.fetchAll(runCompletionIn: nil) { (optionalModels, optionalError) in
                models = optionalModels
                error = optionalError

                semaphore.signal()
            }

            semaphore.wait()

            if let existingModels = models {
                return existingModels
            }

            if let existingError = error {
                throw existingError
            } else {
                throw CoreDataRepositoryError.undefined
            }
        }
    }

    public func fetchOperation(by offset: Int, count: Int, reversed: Bool) -> BaseOperation<[Model]> {
        return ClosureOperation {
            var models: [Model]?
            var error: Error?

            let semaphore = DispatchSemaphore(value: 0)

            self.fetch(offset: offset, count: count,
                       reversed: reversed, runCompletionIn: nil) { (optionalModels, optionalError) in
                        models = optionalModels
                        error = optionalError

                        semaphore.signal()
            }

            semaphore.wait()

            if let existingModels = models {
                return existingModels
            }

            if let existingError = error {
                throw existingError
            } else {
                throw CoreDataRepositoryError.undefined
            }
        }
    }

    public func saveOperation(_ updateModelsBlock: @escaping () throws -> [Model],
                              _ deleteIdsBlock: @escaping () throws -> [String]) -> BaseOperation<Void> {
        return ClosureOperation {
            var error: Error?

            let updatedModels = try updateModelsBlock()
            let deletedIds = try deleteIdsBlock()

            if updatedModels.count == 0, deletedIds.count == 0 {
                return
            }

            let semaphore = DispatchSemaphore(value: 0)

            self.save(updating: updatedModels,
                      deleting: deletedIds,
                      runCompletionIn: nil) { (optionalError) in
                        error = optionalError
                        semaphore.signal()
            }

            semaphore.wait()

            if let existingError = error {
                throw existingError
            }
        }
    }

    public func deleteAllOperation() -> BaseOperation<Void> {
        return ClosureOperation {
            var error: Error?

            let semaphore = DispatchSemaphore(value: 0)

            self.deleteAll(runCompletionIn: nil) { (optionalError) in
                error = optionalError
                semaphore.signal()
            }

            semaphore.wait()

            if let existingError = error {
                throw existingError
            }
        }
    }
}