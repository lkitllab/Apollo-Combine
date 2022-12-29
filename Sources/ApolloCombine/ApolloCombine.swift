import ApolloAPI
import Apollo
import Combine

public protocol ApolloCombine {
    
    func fetch<Query: GraphQLQuery, T>(
        _ query: Query,
        cachePolicy: CachePolicy,
        data: @escaping (Query.Data?)->T?)
    -> Future<T?, Error>
    
    func perform<Mutation: GraphQLMutation, T>(
        _ mutation: Mutation,
        publishResultToStore: Bool,
        data: @escaping (Mutation.Data?)->T?)
    -> Future<T?, Error>
    
    func upload<Operation: GraphQLOperation, T>(
        operation: Operation,
        files: [GraphQLFile],
        data: @escaping (Operation.Data?)->T?
    ) -> Future<T?, Error>
    
    func subscribe<Subscription: GraphQLSubscription, T>(
        _ subscription: Subscription,
        data: @escaping (Subscription.Data?)->T?
    ) -> Future<T?, Error>
}

extension ApolloClient: ApolloCombine {
    
    public func fetch<Query, T>(_ query: Query, cachePolicy: Apollo.CachePolicy, data: @escaping (Query.Data?) -> T?) -> Future<T?, Error> where Query : ApolloAPI.GraphQLQuery {
        Future { [unowned self] promise in
            self.fetch(query: query, cachePolicy: cachePolicy) { queryResult in
                switch queryResult {
                case .success(let graphQLResult):
                    guard let error = graphQLResult.errors?.first else {
                        promise(.success(data(graphQLResult.data)))
                        return
                    }
                    promise(.failure(error))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func perform<Mutation, T>(_ mutation: Mutation, publishResultToStore: Bool, data: @escaping (Mutation.Data?) -> T?) -> Future<T?, Error> where Mutation : ApolloAPI.GraphQLMutation {
        Future { [unowned self] promise in
            self.perform(mutation: mutation, publishResultToStore: publishResultToStore) { queryResult in
                switch queryResult {
                case .success(let graphQLResult):
                    guard let error = graphQLResult.errors?.first else {
                        promise(.success(data(graphQLResult.data)))
                        return
                    }
                    promise(.failure(error))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func upload<Operation, T>(operation: Operation, files: [Apollo.GraphQLFile], data: @escaping (Operation.Data?) -> T?) -> Future<T?, Error> where Operation : ApolloAPI.GraphQLOperation {
        Future { [unowned self] promise in
            self.upload(operation: operation, files: files) { uploadResult in
                switch uploadResult {
                case .success(let graphQLResult):
                    guard let error = graphQLResult.errors?.first else {
                        promise(.success(data(graphQLResult.data)))
                        return
                    }
                    promise(.failure(error))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    public func subscribe<Subscription, T>(_ subscription: Subscription, data: @escaping (Subscription.Data?) -> T?) -> Future<T?, Error> where Subscription : ApolloAPI.GraphQLSubscription {
        Future { [unowned self] promise in
            self.subscribe(subscription: subscription) { result in
                switch result {
                case .success(let graphQLResult):
                    guard let error = graphQLResult.errors?.first else {
                        promise(.success(data(graphQLResult.data)))
                        return
                    }
                    promise(.failure(error))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
}
