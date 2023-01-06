import ApolloAPI
import Apollo
import Combine

public protocol ApolloCombine {
    
    func fetch<Query: GraphQLQuery, T>(
        _ query: Query,
        cachePolicy: CachePolicy,
        data: @escaping (Query.Data?)->T?)
    -> AnyPublisher<T?, Error>
    
    func perform<Mutation: GraphQLMutation, T>(
        _ mutation: Mutation,
        publishResultToStore: Bool,
        data: @escaping (Mutation.Data?)->T?)
    -> AnyPublisher<T?, Error>
    
    func upload<Operation: GraphQLOperation, T>(
        _ operation: Operation,
        files: [GraphQLFile],
        data: @escaping (Operation.Data?)->T?
    ) -> AnyPublisher<T?, Error>
    
    func subscribe<Subscription: GraphQLSubscription, T>(
        _ subscription: Subscription,
        data: @escaping (Subscription.Data?)->T?
    ) -> AnyPublisher<T?, Error>
}

extension ApolloClient: ApolloCombine {
    
    public func fetch<Query, T>(
        _ query: Query,
        cachePolicy: Apollo.CachePolicy,
        data: @escaping (Query.Data?) -> T?
    ) -> AnyPublisher<T?, Error> where Query : ApolloAPI.GraphQLQuery {
        Future { [unowned self] promise in
            fetch(query: query, cachePolicy: cachePolicy) { result in
                do {
                    let resultData = try result.get().data
                    promise(.success(data(resultData)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func perform<Mutation, T>(
        _ mutation: Mutation,
        publishResultToStore: Bool,
        data: @escaping (Mutation.Data?) -> T?
    ) -> AnyPublisher<T?, Error> where Mutation : ApolloAPI.GraphQLMutation {
        Future { [unowned self] promise in
            perform(mutation: mutation, publishResultToStore: publishResultToStore) { result in
                do {
                    let resultData = try result.get().data
                    promise(.success(data(resultData)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func upload<Operation, T>(
        _ operation: Operation,
        files: [Apollo.GraphQLFile],
        data: @escaping (Operation.Data?) -> T?
    ) -> AnyPublisher<T?, Error> where Operation : ApolloAPI.GraphQLOperation {
        Future { [unowned self] promise in
            upload(operation: operation, files: files) { result in
                do {
                    let resultData = try result.get().data
                    promise(.success(data(resultData)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func subscribe<Subscription, T>(
        _ subscription: Subscription,
        data: @escaping (Subscription.Data?) -> T?
    ) -> AnyPublisher<T?, Error> where Subscription : ApolloAPI.GraphQLSubscription {
        Future { [unowned self] promise in
            subscribe(subscription: subscription) { result in
                do {
                    let resultData = try result.get().data
                    promise(.success(data(resultData)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
