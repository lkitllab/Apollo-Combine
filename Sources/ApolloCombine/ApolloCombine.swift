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
            self.fetch(query: query, cachePolicy: cachePolicy) { result in
                self.processGraphQLResult(
                    result,
                    promise: promise,
                    data: data
                )
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
                self.processGraphQLResult(
                    result,
                    promise: promise,
                    data: data
                )
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
                self.processGraphQLResult(
                    result,
                    promise: promise,
                    data: data
                )
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
                self.processGraphQLResult(
                    result,
                    promise: promise,
                    data: data
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func processGraphQLResult<Data: RootSelectionSet, T>(
        _ result : Result<GraphQLResult<Data>, Error>,
        promise: (Result<T?, Error>) -> Void,
        data: (Data?) -> T?
    ) {
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
